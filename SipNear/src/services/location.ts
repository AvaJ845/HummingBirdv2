import * as Location from 'expo-location';
import { Coordinates } from '../types';

/** Napa Valley — used when permission is denied or location fails. */
export const DEFAULT_LOCATION: Coordinates = {
  latitude: 38.5025,
  longitude: -122.2654,
};

export type LocationResult = {
  coords: Coordinates;
  granted: boolean;
  usingFallback: boolean;
  label: string;
};

export async function requestNearbyLocation(): Promise<LocationResult> {
  try {
    const current = await Location.getForegroundPermissionsAsync();
    let status = current.status;

    if (status !== 'granted') {
      const requested = await Location.requestForegroundPermissionsAsync();
      status = requested.status;
    }

    if (status !== 'granted') {
      return {
        coords: DEFAULT_LOCATION,
        granted: false,
        usingFallback: true,
        label: 'Napa Valley (demo area)',
      };
    }

    const position = await Location.getCurrentPositionAsync({
      accuracy: Location.Accuracy.Balanced,
    });

    return {
      coords: {
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
      },
      granted: true,
      usingFallback: false,
      label: 'Near you',
    };
  } catch {
    return {
      coords: DEFAULT_LOCATION,
      granted: false,
      usingFallback: true,
      label: 'Napa Valley (demo area)',
    };
  }
}

export function formatDistance(meters?: number): string {
  if (meters == null || Number.isNaN(meters)) return '';
  if (meters < 1000) return `${Math.round(meters)} m`;
  const miles = meters / 1609.344;
  if (miles < 10) return `${miles.toFixed(1)} mi`;
  return `${Math.round(miles)} mi`;
}
