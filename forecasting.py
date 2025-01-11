# forecasting.py
import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go
from prophet import Prophet
from typing import Tuple, Optional, Dict
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def prepare_data_for_prophet(data: pd.DataFrame) -> pd.DataFrame:
    """Prepare data for Prophet model"""
    try:
        logger.info("Starting data preparation for Prophet")
        logger.info(f"Input data shape: {data.shape}")
        logger.info(f"Input data columns: {data.columns.tolist()}")
        
        # Make a copy of the data
        df = data.copy()
        
        # If the dataframe has a DatetimeIndex, reset it
        if isinstance(df.index, pd.DatetimeIndex):
            df = df.reset_index()
            date_col = df.columns[0]  # The first column will be the former index
        else:
            # Try to find the date column
            date_cols = [col for col in df.columns if col.lower() in ['date', 'timestamp', 'time']]
            date_col = date_cols[0] if date_cols else df.columns[0]
        
        # Convert date column to datetime if it's not already
        df[date_col] = pd.to_datetime(df[date_col])
        
        # Find the value column (assuming it's 'Close' or the first numeric column)
        if 'Close' in df.columns:
            value_col = 'Close'
        else:
            numeric_cols = df.select_dtypes(include=[np.number]).columns
            value_col = numeric_cols[0]
        
        # Create Prophet dataframe with required 'ds' and 'y' columns
        prophet_df = pd.DataFrame({
            'ds': df[date_col],
            'y': df[value_col].astype(float)  # Ensure numeric type
        })
        
        # Sort by date and reset index
        prophet_df = prophet_df.sort_values('ds').reset_index(drop=True)
        
        logger.info(f"Prepared Prophet dataframe shape: {prophet_df.shape}")
        logger.info(f"Sample of prepared data: {prophet_df.head()}")
        
        return prophet_df
    
    except Exception as e:
        logger.error(f"Error in prepare_data_for_prophet: {str(e)}")
        raise Exception(f"Failed to prepare data for Prophet: {str(e)}")

def prophet_forecast(data: pd.DataFrame, periods: int, economic_data: Optional[pd.DataFrame] = None) -> Tuple[Optional[pd.DataFrame], Optional[str]]:
    """Generate forecast using Prophet model"""
    try:
        logger.info(f"Starting forecast for {periods} periods")
        
        # Prepare data for Prophet
        prophet_df = prepare_data_for_prophet(data)
        logger.info(f"Prophet input data shape: {prophet_df.shape}")
        
        # Validate prepared data
        if prophet_df.empty:
            raise ValueError("Prepared dataframe is empty")
        if not np.isfinite(prophet_df['y']).all():
            raise ValueError("Data contains non-finite values")

        # Initialize Prophet model
        model = Prophet(
            daily_seasonality=True,
            weekly_seasonality=True,
            yearly_seasonality=True,
            changepoint_prior_scale=0.05,
            interval_width=0.95
        )

        # Add economic indicator if available
        if economic_data is not None:
            logger.info("Processing economic indicator data")
            economic_df = economic_data.copy()
            
            # Prepare economic data for Prophet
            if isinstance(economic_df.index, pd.DatetimeIndex):
                economic_df = economic_df.reset_index()
            
            if 'value' in economic_df.columns:
                economic_df = pd.DataFrame({
                    'ds': pd.to_datetime(economic_df['index']),
                    'economic_indicator': economic_df['value'].astype(float)
                })
            else:
                economic_df = pd.DataFrame({
                    'ds': pd.to_datetime(economic_df.iloc[:, 0]),
                    'economic_indicator': economic_df.iloc[:, 1].astype(float)
                })

            # Merge with prophet data
            prophet_df = prophet_df.merge(economic_df, on='ds', how='left')
            prophet_df['economic_indicator'] = prophet_df['economic_indicator'].fillna(method='ffill').fillna(method='bfill')
            
            # Add regressor
            model.add_regressor('economic_indicator', mode='multiplicative')

        # Fit the model
        logger.info("Fitting Prophet model")
        model.fit(prophet_df)

        # Create future dataframe
        logger.info(f"Creating future dataframe for {periods} periods")
        future = model.make_future_dataframe(periods=periods)
        
        # Add economic indicator to future if available
        if economic_data is not None:
            future = future.merge(economic_df, on='ds', how='left')
            future['economic_indicator'] = future['economic_indicator'].fillna(method='ffill').fillna(method='bfill')

        # Generate forecast
        logger.info("Generating forecast")
        forecast = model.predict(future)
        
        # Add actual values to forecast dataframe
        forecast['actual'] = np.nan
        forecast.loc[forecast['ds'].isin(prophet_df['ds']), 'actual'] = prophet_df['y'].values
        
        logger.info("Forecast completed successfully")
        return forecast, None

    except Exception as e:
        logger.error(f"Error in prophet_forecast: {str(e)}")
        st.error(f"Forecasting error details: {str(e)}")
        return None, str(e)

def create_forecast_plot(data: pd.DataFrame, forecast: pd.DataFrame, model_name: str, symbol: str) -> go.Figure:
    """Create an interactive plot with historical data and forecast"""
    try:
        fig = go.Figure()

        # Historical data
        if isinstance(data.index, pd.DatetimeIndex):
            dates = data.index
            values = data['Close'] if 'Close' in data.columns else data.iloc[:, 0]
        else:
            dates = pd.to_datetime(data['Date'] if 'Date' in data.columns else data['timestamp'])
            values = data['Close'] if 'Close' in data.columns else data.iloc[:, 1]

        # Add historical data trace
        fig.add_trace(go.Scatter(
            x=dates,
            y=values,
            name='Historical',
            line=dict(color='blue'),
            hovertemplate='Date: %{x}<br>Price: $%{y:.2f}<extra></extra>'
        ))

        # Add forecast trace
        fig.add_trace(go.Scatter(
            x=forecast['ds'],
            y=forecast['yhat'],
            name=f'{model_name} Forecast',
            line=dict(color='red', dash='dot'),
            hovertemplate='Date: %{x}<br>Forecast: $%{y:.2f}<extra></extra>'
        ))

        # Add confidence interval
        fig.add_trace(go.Scatter(
            x=pd.concat([forecast['ds'], forecast['ds'][::-1]]),
            y=pd.concat([forecast['yhat_upper'], forecast['yhat_lower'][::-1]]),
            fill='toself',
            fillcolor='rgba(255,0,0,0.1)',
            line=dict(color='rgba(255,0,0,0)'),
            name='95% Confidence Interval',
            hoverinfo='skip'
        ))

        # Update layout
        fig.update_layout(
            title={
                'text': f'{symbol} Price Forecast',
                'y':0.95,
                'x':0.5,
                'xanchor': 'center',
                'yanchor': 'top'
            },
            xaxis_title='Date',
            yaxis_title='Price ($)',
            hovermode='x unified',
            showlegend=True,
            template='plotly_white',
            legend=dict(
                yanchor="top",
                y=0.99,
                xanchor="left",
                x=0.01
            ),
            margin=dict(l=50, r=50, t=50, b=50)
        )

        return fig

    except Exception as e:
        logger.error(f"Error creating forecast plot: {str(e)}")
        st.error(f"Error creating plot: {str(e)}")
        return None

def display_metrics(data: pd.DataFrame, forecast: pd.DataFrame, asset_type: str, symbol: str):
    """Display key metrics and statistics"""
    try:
        # Calculate metrics
        latest_price = data['Close'].iloc[-1] if 'Close' in data.columns else data.iloc[:, 1].iloc[-1]
        forecast_price = forecast['yhat'].iloc[-1]
        price_change = ((forecast_price - latest_price) / latest_price) * 100

        # Create metrics display
        col1, col2, col3 = st.columns(3)

        # Current Price
        with col1:
            if 'Close' in data.columns:
                change = data['Close'].pct_change().iloc[-1] * 100
            else:
                change = (data.iloc[-1, 1] / data.iloc[-2, 1] - 1) * 100
            
            st.metric(
                "Current Price",
                f"${latest_price:.2f}",
                f"{change:.2f}%"
            )

        # Forecast Price
        with col2:
            st.metric(
                f"Forecast Price ({forecast['ds'].iloc[-1].strftime('%Y-%m-%d')})",
                f"${forecast_price:.2f}",
                f"{price_change:.2f}%"
            )

        # Confidence Range
        with col3:
            confidence_range = forecast['yhat_upper'].iloc[-1] - forecast['yhat_lower'].iloc[-1]
            st.metric(
                "Forecast Range",
                f"${confidence_range:.2f}",
                f"±{(confidence_range/forecast_price*100/2):.2f}%"
            )

    except Exception as e:
        logger.error(f"Error displaying metrics: {str(e)}")
        st.error(f"Error displaying metrics: {str(e)}")

def display_economic_indicators(data: pd.DataFrame, indicator: str, economic_indicators: object):
    """Display economic indicator information and analysis"""
    try:
        st.subheader("📊 Economic Indicator Analysis")
        
        # Get indicator details
        indicator_info = economic_indicators.get_indicator_info(indicator)
        
        # Display indicator information
        st.markdown(f"""
            **Indicator:** {indicator_info.get('description', indicator)}  
            **Frequency:** {indicator_info.get('frequency', 'N/A')}  
            **Units:** {indicator_info.get('units', 'N/A')}
        """)
        
        # Get and display analysis
        analysis = economic_indicators.analyze_indicator(data, indicator)
        if analysis:
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.metric(
                    "Current Value",
                    f"{analysis['current_value']:.2f}",
                    f"{analysis['change_1d']:.2f}% (1d)"
                )
            
            with col2:
                if analysis.get('change_1m') is not None:
                    st.metric(
                        "Monthly Change",
                        f"{analysis['current_value']:.2f}",
                        f"{analysis['change_1m']:.2f}% (1m)"
                    )
            
            with col3:
                st.metric(
                    "Average Value",
                    f"{analysis['avg_value']:.2f}",
                    f"σ: {analysis['std_dev']:.2f}"
                )

    except Exception as e:
        logger.error(f"Error displaying economic indicators: {str(e)}")
        st.error(f"Error displaying economic indicators: {str(e)}")