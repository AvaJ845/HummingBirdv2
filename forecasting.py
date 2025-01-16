#Forecasting.py
import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from prophet import Prophet
from typing import Tuple, Optional, Dict
import logging
from asset_config import AssetConfig

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def prepare_data_for_prophet(data: pd.DataFrame) -> pd.DataFrame:
    """Prepare data for Prophet model"""
    try:
        logger.info("Starting data preparation for Prophet")
        df = data.copy()
        
        if isinstance(df.index, pd.DatetimeIndex):
            df = df.reset_index()
            df.rename(columns={'index': 'ds'}, inplace=True)

        if 'Close' in df.columns:
            if 'ds' not in df.columns:
                date_cols = [col for col in df.columns if isinstance(col, str) and col.lower() in ['date', 'timestamp', 'time']]
                if date_cols:
                    df.rename(columns={date_cols[0]: 'ds'}, inplace=True)
                else:
                    df['ds'] = df.index
            df['y'] = df['Close']
        else:
            numeric_cols = df.select_dtypes(include=[np.number]).columns
            if len(numeric_cols) > 0:
                if 'ds' not in df.columns:
                    df['ds'] = df.index
                df['y'] = df[numeric_cols[0]]

        df['ds'] = pd.to_datetime(df['ds'])
        df['y'] = df['y'].astype(float)
        prophet_df = df[['ds', 'y']].sort_values('ds').reset_index(drop=True).dropna()
        return prophet_df

    except Exception as e:
        logger.error(f"Error in prepare_data_for_prophet: {str(e)}")
        raise Exception(f"Failed to prepare data for Prophet: {str(e)}")

def add_crypto_specific_indicators(df: pd.DataFrame) -> pd.DataFrame:
    """Add cryptocurrency-specific indicators"""
    try:
        df['volume_ma'] = df['Volume'].rolling(window=24).mean()
        df['volume_ratio'] = df['Volume'] / df['volume_ma']
        df['hourly_volatility'] = df['Close'].pct_change().rolling(window=24).std()
        df['volatility_ratio'] = df['hourly_volatility'] / df['hourly_volatility'].rolling(window=168).mean()
        df['market_dominance'] = 0.5  # Placeholder
        df['network_transactions'] = 0.5  # Placeholder
        df['active_addresses'] = 0.5  # Placeholder
        return df
    except Exception as e:
        logger.error(f"Error adding crypto indicators: {str(e)}")
        return df

def add_technical_indicators(df: pd.DataFrame, asset_type: str = 'stocks') -> pd.DataFrame:
    """Add technical indicators based on asset type"""
    try:
        config = AssetConfig.get_config(asset_type)
        indicators = config['indicators']
        
        # Moving Averages
        df['MA5'] = df['Close'].rolling(window=indicators['ma_periods'][0]).mean()
        df['MA20'] = df['Close'].rolling(window=indicators['ma_periods'][1]).mean()
        df['MA50'] = df['Close'].rolling(window=indicators['ma_periods'][2]).mean()
        
        # RSI
        delta = df['Close'].diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=indicators['rsi_period']).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=indicators['rsi_period']).mean()
        rs = gain / loss
        df['RSI'] = 100 - (100 / (1 + rs))
        
        # MACD
        macd_fast, macd_slow, signal = indicators['macd_periods']
        exp1 = df['Close'].ewm(span=macd_fast, adjust=False).mean()
        exp2 = df['Close'].ewm(span=macd_slow, adjust=False).mean()
        df['MACD'] = exp1 - exp2
        df['Signal_Line'] = df['MACD'].ewm(span=signal, adjust=False).mean()
        
        if asset_type.lower() == 'crypto':
            df = add_crypto_specific_indicators(df)
        
        return df
    except Exception as e:
        logger.error(f"Error in add_technical_indicators: {str(e)}")
        return df
        
        def prophet_forecast(data: pd.DataFrame, periods: int, economic_data: Optional[pd.DataFrame] = None,
                     indicator: Optional[str] = None, asset_type: str = 'stocks') -> Tuple[Optional[pd.DataFrame], Optional[str]]:
    """Generate forecast using Prophet model"""
    try:
        if data is None or data.empty:
            return None, "No data provided for forecasting"

        prophet_df = prepare_data_for_prophet(data)
        if prophet_df is None or prophet_df.empty:
            return None, "No valid data for forecasting"

        model = Prophet(
            changepoint_prior_scale=0.05,
            yearly_seasonality=True,
            weekly_seasonality=True,
            daily_seasonality=False
        )

        model.add_seasonality(
            name='monthly',
            period=30.5,
            fourier_order=5
        )

        if economic_data is not None:
            if indicator == 'POLSENT':
                economic_df = economic_data.copy()
                economic_df.columns = ['ds', 'sentiment']
                prophet_df = prophet_df.merge(economic_df, on='ds', how='left')
                prophet_df['sentiment'] = prophet_df['sentiment'].fillna(
                    prophet_df['sentiment'].rolling(window=7, min_periods=1).mean()
                )
                model.add_regressor('sentiment', mode='multiplicative')
            else:
                economic_df = economic_data.copy()
                economic_df.columns = ['ds', 'economic_indicator']
                prophet_df = prophet_df.merge(economic_df, on='ds', how='left')
                prophet_df['economic_indicator'] = prophet_df['economic_indicator'].fillna(method='ffill').fillna(method='bfill')
                model.add_regressor('economic_indicator', mode='multiplicative')

        model.fit(prophet_df)
        future = model.make_future_dataframe(periods=periods)

        if economic_data is not None:
            if indicator == 'POLSENT':
                future = future.merge(economic_df[['ds', 'sentiment']], on='ds', how='left')
                future['sentiment'] = future['sentiment'].fillna(prophet_df['sentiment'].mean())
            else:
                future = future.merge(economic_df[['ds', 'economic_indicator']], on='ds', how='left')
                future['economic_indicator'] = future['economic_indicator'].fillna(method='ffill').fillna(method='bfill')

        forecast = model.predict(future)
        forecast['actual'] = np.nan
        forecast.loc[forecast['ds'].isin(prophet_df['ds']), 'actual'] = prophet_df['y'].values

        return forecast, None

    except Exception as e:
        logger.error(f"Error in prophet_forecast: {str(e)}")
        return None, str(e)

def create_forecast_plot(data: pd.DataFrame, forecast: pd.DataFrame, model_name: str, symbol: str) -> go.Figure:
    """Create an interactive plot with historical data and forecast"""
    try:
        fig = make_subplots(rows=2, cols=1, 
                           shared_xaxes=True, 
                           vertical_spacing=0.03, 
                           row_heights=[0.7, 0.3],
                           subplot_titles=(f'{symbol} Price Forecast', 'Confidence Analysis'))

        # Add historical data
        if isinstance(data.index, pd.DatetimeIndex):
            historical_dates = data.index
        else:
            historical_dates = pd.to_datetime(data.index)
        
        fig.add_trace(
            go.Candlestick(
                x=historical_dates,
                open=data['Open'],
                high=data['High'],
                low=data['Low'],
                close=data['Close'],
                name='Historical',
                increasing_line_color='green',
                decreasing_line_color='red'
            ),
            row=1, col=1
        )

        # Add forecast
        fig.add_trace(
            go.Scatter(
                x=forecast['ds'],
                y=forecast['yhat'],
                name='Forecast',
                line=dict(color='blue', dash='dash')
            ),
            row=1, col=1
        )

        # Add confidence intervals
        fig.add_trace(
            go.Scatter(
                x=pd.concat([forecast['ds'], forecast['ds'][::-1]]),
                y=pd.concat([forecast['yhat_upper'], forecast['yhat_lower'][::-1]]),
                fill='toself',
                fillcolor='rgba(0,100,255,0.2)',
                line=dict(color='rgba(255,255,255,0)'),
                name='95% Confidence Interval'
            ),
            row=1, col=1
        )

        # Add confidence width analysis
        confidence_width = (forecast['yhat_upper'] - forecast['yhat_lower']) / forecast['yhat'] * 100
        fig.add_trace(
            go.Scatter(
                x=forecast['ds'],
                y=confidence_width,
                name='Confidence Width',
                line=dict(color='purple')
            ),
            row=2, col=1
        )

        fig.update_layout(
            title=f'{symbol} Price Forecast',
            yaxis_title='Price ($)',
            yaxis2_title='Confidence Width (%)',
            height=800
        )

        return fig

    except Exception as e:
        logger.error(f"Error creating forecast plot: {str(e)}")
        return None
        
        def display_common_metrics(data: pd.DataFrame, forecast: pd.DataFrame):
    """Display common metrics for both stocks and cryptocurrencies"""
    try:
        st.subheader("📈 Price Metrics")
        
        current_price = float(data['Close'].iloc[-1])
        price_change = float(data['Close'].pct_change().iloc[-1] * 100)
        forecast_price = float(forecast['yhat'].iloc[-1])
        forecast_change = ((forecast_price / current_price) - 1) * 100
        
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Current Price", f"${current_price:,.2f}", f"{price_change:+.2f}%")
        with col2:
            st.metric("Forecast Price", f"${forecast_price:,.2f}", f"{forecast_change:+.2f}%")
        with col3:
            volatility = float(data['Close'].pct_change().std() * np.sqrt(252) * 100)
            st.metric("Annual Volatility", f"{volatility:.1f}%")

    except Exception as e:
        logger.error(f"Error displaying common metrics: {str(e)}")
        st.error(f"Error displaying common metrics: {str(e)}")

def display_confidence_analysis(forecast: pd.DataFrame):
    """Display confidence analysis of the forecast"""
    try:
        st.subheader("📊 Confidence Analysis")

        confidence_width = (forecast['yhat_upper'] - forecast['yhat_lower']) / forecast['yhat'] * 100
        avg_confidence = 100 - confidence_width.mean()
        total_trend = ((forecast['yhat'].iloc[-1] / forecast['yhat'].iloc[0]) - 1) * 100
        
        col1, col2 = st.columns(2)
        with col1:
            st.metric("Average Confidence", f"{avg_confidence:.1f}%")
        with col2:
            st.metric("Overall Trend", f"{total_trend:+.1f}%")

    except Exception as e:
        logger.error(f"Error displaying confidence analysis: {str(e)}")
        st.error(f"Error displaying confidence analysis: {str(e)}")

def display_crypto_metrics(data: pd.DataFrame, forecast: pd.DataFrame, symbol: str):
    """Display cryptocurrency-specific metrics"""
    try:
        st.subheader("🪙 Cryptocurrency Metrics")

        if 'Volume' in data.columns:
            col1, col2 = st.columns(2)
            with col1:
                volume = float(data['Volume'].iloc[-1])
                volume_change = float(data['Volume'].pct_change().iloc[-1] * 100)
                st.metric("24h Volume", f"${volume:,.0f}", f"{volume_change:+.2f}%")
            with col2:
                if 'volume_ratio' in data.columns:
                    vol_ratio = float(data['volume_ratio'].iloc[-1])
                    st.metric("Volume Ratio", f"{vol_ratio:.2f}")

    except Exception as e:
        logger.error(f"Error displaying crypto metrics: {str(e)}")
        st.error(f"Error displaying crypto metrics: {str(e)}")

def display_metrics(data: pd.DataFrame, forecast: pd.DataFrame, asset_type: str, symbol: str):
    """Display all metrics"""
    try:
        display_common_metrics(data, forecast)
        if asset_type