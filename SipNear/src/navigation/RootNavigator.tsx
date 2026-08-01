import { Ionicons } from '@expo/vector-icons';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { NavigationContainer, DefaultTheme } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import React, { useState } from 'react';
import { DiscoverScreen } from '../screens/DiscoverScreen';
import { HomeScreen } from '../screens/HomeScreen';
import { NearbyScreen } from '../screens/NearbyScreen';
import { SavedScreen } from '../screens/SavedScreen';
import { WelcomeScreen } from '../screens/WelcomeScreen';
import { WineDetailScreen } from '../screens/WineDetailScreen';
import { WineryDetailScreen } from '../screens/WineryDetailScreen';
import { colors } from '../theme/colors';
import { MainTabParamList, RootStackParamList } from './types';

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<MainTabParamList>();

const navTheme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    background: colors.cream,
    card: colors.parchment,
    text: colors.ink,
    border: colors.border,
    primary: colors.burgundy,
  },
};

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor: colors.burgundy,
        tabBarInactiveTintColor: colors.muted,
        tabBarStyle: {
          backgroundColor: colors.parchment,
          borderTopColor: colors.border,
          height: 64,
          paddingBottom: 8,
          paddingTop: 6,
        },
        tabBarLabelStyle: {
          fontWeight: '700',
          fontSize: 11,
        },
        tabBarIcon: ({ color, size }) => {
          const icon =
            route.name === 'Home'
              ? 'home'
              : route.name === 'Nearby'
                ? 'map'
                : 'wine';
          return <Ionicons name={icon} size={size} color={color} />;
        },
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Nearby" component={NearbyScreen} />
      <Tab.Screen name="Discover" component={DiscoverScreen} />
    </Tab.Navigator>
  );
}

function AppStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="MainTabs" component={MainTabs} />
      <Stack.Screen
        name="WineDetail"
        component={WineDetailScreen}
        options={{ presentation: 'modal' }}
      />
      <Stack.Screen name="WineryDetail" component={WineryDetailScreen} />
      <Stack.Screen name="Saved" component={SavedScreen} />
    </Stack.Navigator>
  );
}

export function RootNavigator() {
  const [welcomeDone, setWelcomeDone] = useState(false);

  if (!welcomeDone) {
    return <WelcomeScreen onContinue={() => setWelcomeDone(true)} />;
  }

  return (
    <NavigationContainer theme={navTheme}>
      <AppStack />
    </NavigationContainer>
  );
}
