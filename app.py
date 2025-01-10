"""
Main application file for HummingBird v2
"""

import streamlit as st
from config import Config, MODEL_DESCRIPTIONS
from data_fetchers import (
    AssetDataFetcher,
    EconomicIndicators,
    RealEstateIndicators,
    GDELTDataFetcher,
    IntegratedDataFetcher
)
from forecasting import Forecasting


def display_footer():
    """Display the application footer"""
    st.markdown("""
        <div style='text-align: center; padding: 10px;'>
            <p>© 2025 AvaResearch LLC. All rights reserved.</p>
        </div>
    """, unsafe_allow_html=True)


def handle_error(error: Exception, context: str = ""):
    """Enhanced error handling with context"""
    error_type = type(error).__name__
    if context:
        st.error(f"Error in {context}: {str(error)}")
    else:
        st.error(f"{error_type}: {str(error)}")

    if st.checkbox("Show detailed error information"):
        st.exception(error)


def validate_inputs(symbol: str, periods: int, asset_type: str) -> bool:
    """Validate user inputs"""
    if not symbol:
        st.error("Please enter a symbol.")
        return False

    if periods < 7 or periods > 90:
        st.error("Forecast period must be between 7 and 90 days.")
        return False

    if asset_type not in Config.ASSET_TYPES:
        st.error("Invalid asset type selected.")
        return False

    return True


def initialize_session_state():
    """Initialize or reset session state variables"""
    if "economic_indicators" not in st.session_state:
        st.session_state.economic_indicators = EconomicIndicators()
    if "real_estate_indicators" not in st.session_state:
        st.session_state.real_estate_indicators = RealEstateIndicators()
    if "integrated_data_fetcher" not in st.session_state:
        st.session_state.integrated_data_fetcher = IntegratedDataFetcher()
    if "forecaster" not in st.session_state:
        st.session_state.forecaster = Forecasting()


def main():
    try:
        # Page configuration
        st.set_page_config(
            page_title="HummingBird v2",
            page_icon="🐦",
            layout="wide"
        )

        # Initialize session state
        initialize_session_state()

        # Branding
        st.markdown("""
            <div style='text-align: center;'>
                <h1>🐦 HummingBird v2</h1>
                <p><i>Digital Asset Stock Forecasting with Economic and Market Sentiment Indicators</i></p>
                <p>AvaResearch LLC - A Black Collar Production</p>
            </div>
        """, unsafe_allow_html=True)

        # Sidebar - Model selection
        st.sidebar.header("🔮 Select Forecasting Model")
        selected_model = st.sidebar.selectbox(
            "Choose a forecasting model:",
            options=list(MODEL_DESCRIPTIONS.keys()),
            format_func=lambda x: f"{x}: {MODEL_DESCRIPTIONS[x]}"
        )

        # Sidebar - Forecasting parameters
        st.sidebar.header("🔧 Forecast Parameters")
        symbol = st.sidebar.text_input("Enter the symbol (e.g., AAPL, BTC-USD):")
        asset_type = st.sidebar.selectbox("Asset Type:", Config.ASSET_TYPES)
        forecast_period = st.sidebar.slider("Forecast Period (days):", 7, 90, 30)

        # Additional options
        st.sidebar.header("📊 Additional Indicators")
        include_sentiment = st.sidebar.checkbox("Include Sentiment Analysis", value=True)
        include_economic = st.sidebar.checkbox("Include Economic Indicators", value=True)

        if validate_inputs(symbol, forecast_period, asset_type):
            # Data fetching
            fetcher = AssetDataFetcher(asset_type, symbol)
            historical_data = fetcher.get_historical_data()

            # Get additional data
            gdelt_fetcher = GDELTDataFetcher(symbol)
            sentiment_data = gdelt_fetcher.get_sentiment_data() if include_sentiment else None
            economic_data = st.session_state.economic_indicators.get_indicators() if include_economic else None

            # Display metrics
            st.header("📊 Historical Data Overview")
            st.dataframe(historical_data.tail(10))

            # Forecasting
            st.header("🔮 Forecasting Results")
            forecast_df, error = st.session_state.forecaster.prophet_forecast(
                historical_data, 
                forecast_period,
                sentiment_data,
                economic_data
            )

            if error:
                st.error(f"Error generating forecast: {error}")
                return

            # Display forecast plot
            forecast_plot = st.session_state.forecaster.create_forecast_plot(
                historical_data,
                forecast_df,
                selected_model,
                symbol,
                sentiment_data
            )
            st.plotly_chart(forecast_plot, use_container_width=True)

            # Display metrics and components
            st.session_state.forecaster.display_metrics(
                historical_data,
                forecast_df,
                asset_type,
                symbol,
                sentiment_data
            )

            # Create tabs for additional analysis
            tab1, tab2, tab3 = st.tabs(["Components", "Sentiment", "Economic"])

            with tab1:
                st.session_state.forecaster.display_components(forecast_df)

            with tab2:
                if include_sentiment and sentiment_data is not None:
                    st.session_state.forecaster.display_sentiment_analysis(sentiment_data)
                else:
                    st.info("Enable sentiment analysis in the sidebar to view this section.")

            with tab3:
                if include_economic and economic_data is not None:
                    for indicator in Config.ECONOMIC_CONFIG['indicators']:
                        st.session_state.forecaster.display_economic_indicators(
                            economic_data,
                            indicator,
                            st.session_state.economic_indicators,
                            sentiment_data
                        )
                else:
                    st.info("Enable economic indicators in the sidebar to view this section.")

            # Display accuracy metrics
            accuracy_metrics = st.session_state.forecaster.calculate_accuracy(
                historical_data['Close'],
                forecast_df['yhat'][-len(historical_data):]
            )
            
            st.header("📈 Forecast Accuracy")
            for metric, value in accuracy_metrics.items():
                st.metric(metric, f"{value:.2f}")

    except Exception as e:
        handle_error(e, "main application logic")

    # Footer
    display_footer()


if __name__ == "__main__":
    main()