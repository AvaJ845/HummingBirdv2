import { NavigatorScreenParams } from '@react-navigation/native';
import { WineType } from '../types';

export type MainTabParamList = {
  Home: undefined;
  Nearby: undefined;
  Discover: { filter?: WineType } | undefined;
};

export type RootStackParamList = {
  Welcome: undefined;
  MainTabs: NavigatorScreenParams<MainTabParamList> | undefined;
  WineDetail: { id: string };
  WineryDetail: { id: string };
  Saved: undefined;
};
