# data_fetchers.py
import streamlit as st
import yfinance as yf
import pandas as pd
import requests
import fredapi
import numpy as np
from typing import Optional
from datetime import date, timedelta
from config import Config

class EconomicIndicators:
    def __init__(self):
        self.fred = fredapi.Fred(api_key=Config.FRED_API_KEY)
        self._initialize_indicators()
    
    def _initialize_indicators(self):
        """Initialize FRED indicators with descriptions and frequencies"""
        self.indicator_details = {
            'GDP': {
                'series_id': 'GDP',
                'description': 'Gross Domestic Product',
                'frequency': 'Quarterly',
                'units': 'Billions of Dollars'
            },
            'UNRATE': {
                'series_id': 'UNRATE',
                'description': 'Unemployment Rate',
                'frequency': 'Monthly',
                'units': 'Percent'
            },
            'CPIAUCSL': {
                'series_id': 'CPIAUCSL',
                'description': 'Consumer Price Index',
                'frequency': 'Monthly',
                'units': 'Index 1982-1984=100'
            },
            'DFF': {
                'series_id': 'DFF',
                'description': 'Federal Funds Rate',
                'frequency': 'Daily',
                'units': 'Percent'
            },
            'IEF': {
                'series_id': 'IEF',
                'description': 'iShares 7-10 Year Treasury Bond ETF',
                'frequency': 'Daily',
                'units': 'USD'
            }
        }
    
    @st.cache_data(ttl=Config.CACHE_TTL)
    def get_indicator_data(self, indicator: str) -> Optional[pd.DataFrame]:
        """Fetch and process economic indicator data with proper error handling"""
        try:
            if indicator == 'IEF':
                data = yf.download('IEF', start=Config.START, end=Config.TODAY)
                df = pd.DataFrame(data['Close']).reset_index()
                df.columns = ['index', 'value']
            else:
                indicator_info = self.indicator_details[indicator]
                series_id = indicator_info['series_id']
                
                # Get series information
                series_info = self.fred.get_series_info(series_id)
                
                # Fetch the data
                data = self.fred.get_series(
                    series_id,
                    observation_start=Config.START,
                    observation_end=Config.TODAY,
                    frequency='d'  # Convert to daily frequency
                )
                
                df = pd.DataFrame(data).reset_index()
                df.columns = ['index', 'value']
                
                # Forward fill missing values for non-daily series
                if indicator_info['frequency'] != 'Daily':
                    df['value'] = df['value'].ffill()
                
                # Add metadata
                df.attrs['title'] = indicator_info['description']
                df.attrs['units'] = indicator_info['units']
                df.attrs['frequency'] = indicator_info['frequency']
            
            # Remove timezone information
            df['index'] = pd.to_datetime(df['index']).dt.tz_localize(None)
            return df
            
        except Exception as e:
            st.error(f"Error fetching {indicator} data: {str(e)}")
            return None
    
    def get_indicator_info(self, indicator: str) -> dict:
        """Get metadata for an indicator"""
        return self.indicator_details.get(indicator, {})
    
    def analyze_indicator(self, df: pd.DataFrame, indicator: str) -> dict:
        """Analyze an economic indicator and return key statistics"""
        if df is None or df.empty:
            return {}
            
        try:
            stats = {
                'current_value': df['value'].iloc[-1],
                'change_1d': (df['value'].iloc[-1] - df['value'].iloc[-2]) / df['value'].iloc[-2] * 100,
                'change_1m': (df['value'].iloc[-1] - df['value'].iloc[-30]) / df['value'].iloc[-30] * 100 if len(df) >= 30 else None,
                'min_value': df['value'].min(),
                'max_value': df['value'].max(),
                'avg_value': df['value'].mean(),
                'std_dev': df['value'].std()
            }
            
            # Add trend analysis
            trend_period = 30
            if len(df) >= trend_period:
                recent_values = df['value'].tail(trend_period)
                slope, _ = np.polyfit(range(trend_period), recent_values, 1)
                stats['trend'] = 'Upward' if slope > 0 else 'Downward' if slope < 0 else 'Stable'
            
            return stats
            
        except Exception as e:
            st.error(f"Error analyzing {indicator}: {str(e)}")
            return {}

class AssetDataFetcher:
    @staticmethod
    def get_polygon_data(symbol: str) -> Optional[pd.DataFrame]:
        """Fetch data from Polygon.io as a backup source"""
        try:
            end_date = date.today()
            start_date = end_date - timedelta(days=365)
            
            url = f"https://api.polygon.io/v2/aggs/ticker/{symbol}/range/1/day/{start_date}/{end_date}"
            params = {
                'apiKey': Config.POLYGON_API_KEY,
                'limit': 365
            }
            
            response = requests.get(url, params=params)
            response.raise_for_status()
            
            data = response.json()
            if data['resultsCount'] == 0:
                return None
                
            df = pd.DataFrame(data['results'])
            df['Date'] = pd.to_datetime(df['t'], unit='ms')
            df.set_index('Date', inplace=True)
            
            # Rename columns to match yfinance format
            df = df.rename(columns={
                'o': 'Open',
                'h': 'High',
                'l': 'Low',
                'c': 'Close',
                'v': 'Volume'
            })
            
            return df.sort_index()
            
        except Exception as e:
            st.error(f"Error fetching Polygon data: {str(e)}")
            return None

    @staticmethod
    def get_alpha_vantage_data(symbol: str) -> Optional[pd.DataFrame]:
        """Fetch data from Alpha Vantage as another backup source"""
        try:
            url = 'https://www.alphavantage.co/query'
            params = {
                'function': 'TIME_SERIES_DAILY',
                'symbol': symbol,
                'apikey': Config.ALPHA_VANTAGE_API_KEY,
                'outputsize': 'full'
            }
            
            response = requests.get(url, params=params)
            response.raise_for_status()
            
            data = response.json()
            if "Time Series (Daily)" not in data:
                return None
                
            df = pd.DataFrame(data["Time Series (Daily)"]).T
            df = df.rename(columns={
                '1. open': 'Open',
                '2. high': 'High',
                '3. low': 'Low',
                '4. close': 'Close',
                '5. volume': 'Volume'
            })
            
            for col in df.columns:
                df[col] = pd.to_numeric(df[col])
                
            df.index = pd.to_datetime(df.index)
            return df.last('365D')
            
        except Exception as e:
            st.error(f"Error fetching Alpha Vantage data: {str(e)}")
            return None

    @staticmethod
    @st.cache_data(ttl=Config.CACHE_TTL)
    def get_stock_data(symbol: str) -> Optional[pd.DataFrame]:
        """Fetch stock data with fallback to multiple sources"""
        try:
            # Try Yahoo Finance first
            ticker = yf.Ticker(symbol)
            data = ticker.history(period="1y", interval="1d")
            
            if not data.empty:
                data.index = pd.to_datetime(data.index).tz_localize(None)
                return data
            
            # Try Polygon.io if Yahoo Finance fails
            data = AssetDataFetcher.get_polygon_data(symbol)
            if data is not None:
                return data
            
            # Try Alpha Vantage as last resort
            data = AssetDataFetcher.get_alpha_vantage_data(symbol)
            if data is not None:
                return data
                
            raise ValueError(f"No data available for {symbol} from any source")
            
        except Exception as e:
            st.error(f"Error fetching stock data: {str(e)}")
            return None

    @staticmethod
    @st.cache_data(ttl=Config.CACHE_TTL)
    def get_crypto_data(symbol: str) -> Optional[pd.DataFrame]:
        """Fetch cryptocurrency data from CoinGecko"""
        try:
            url = f"https://api.coingecko.com/api/v3/coins/{symbol}/market_chart"
            params = {
                'vs_currency': 'usd',
                'days': '365',
                'interval': 'daily'
            }
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            df = pd.DataFrame(data['prices'], columns=['Date', 'Close'])
            df['Date'] = pd.to_datetime(df['Date'], unit='ms').tz_localize(None)
            df.set_index('Date', inplace=True)
            
            volume_df = pd.DataFrame(data['total_volumes'], columns=['Date', 'Volume'])
            volume_df['Date'] = pd.to_datetime(volume_df['Date'], unit='ms').tz_localize(None)
            volume_df.set_index('Date', inplace=True)
            df['Volume'] = volume_df['Volume']
            
            return df
            
        except Exception as e:
            st.error(f"Error fetching crypto data: {str(e)}")
            return None

    @staticmethod
    def get_current_price(symbol: str, asset_type: str) -> Optional[float]:
        """Get current price for an asset"""
        try:
            if asset_type == "Stocks":
                ticker = yf.Ticker(symbol)
                price = ticker.info.get('regularMarketPrice')
                if price is None:
                    price = ticker.history(period='1d')['Close'].iloc[-1]
            else:
                url = f'https://api.coingecko.com/api/v3/simple/price'
                params = {'ids': symbol, 'vs_currencies': 'usd'}
                response = requests.get(url, params=params, timeout=10)
                data = response.json()
                price = data[symbol]['usd']
            return price
        except Exception as e:
            st.error(f"Error fetching current price: {str(e)}")
            return None