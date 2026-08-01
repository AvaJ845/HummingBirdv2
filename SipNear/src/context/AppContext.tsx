import AsyncStorage from '@react-native-async-storage/async-storage';
import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';
import { Coordinates, Wine, Winery } from '../types';
import { requestNearbyLocation, LocationResult } from '../services/location';
import { fetchNearbyWineries, NearbyResult } from '../services/wineries';

const SAVED_KEY = 'sipnear.savedWineIds';

type AppContextValue = {
  location: LocationResult | null;
  wineries: Winery[];
  fromFallback: boolean;
  statusMessage?: string;
  loadingLocation: boolean;
  loadingWineries: boolean;
  savedWineIds: string[];
  findNearby: () => Promise<void>;
  refreshWineries: () => Promise<void>;
  toggleSavedWine: (wine: Wine) => void;
  isWineSaved: (id: string) => boolean;
  coords: Coordinates | null;
};

const AppContext = createContext<AppContextValue | null>(null);

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [location, setLocation] = useState<LocationResult | null>(null);
  const [wineries, setWineries] = useState<Winery[]>([]);
  const [fromFallback, setFromFallback] = useState(false);
  const [statusMessage, setStatusMessage] = useState<string | undefined>();
  const [loadingLocation, setLoadingLocation] = useState(false);
  const [loadingWineries, setLoadingWineries] = useState(false);
  const [savedWineIds, setSavedWineIds] = useState<string[]>([]);

  useEffect(() => {
    AsyncStorage.getItem(SAVED_KEY)
      .then((raw) => {
        if (!raw) return;
        const parsed = JSON.parse(raw) as string[];
        if (Array.isArray(parsed)) setSavedWineIds(parsed);
      })
      .catch(() => undefined);
  }, []);

  const loadWineries = useCallback(async (coords: Coordinates) => {
    setLoadingWineries(true);
    try {
      const result: NearbyResult = await fetchNearbyWineries(coords);
      setWineries(result.wineries);
      setFromFallback(result.fromFallback);
      setStatusMessage(result.message);
    } finally {
      setLoadingWineries(false);
    }
  }, []);

  const findNearby = useCallback(async () => {
    setLoadingLocation(true);
    try {
      const loc = await requestNearbyLocation();
      setLocation(loc);
      await loadWineries(loc.coords);
    } finally {
      setLoadingLocation(false);
    }
  }, [loadWineries]);

  const refreshWineries = useCallback(async () => {
    if (!location) {
      await findNearby();
      return;
    }
    await loadWineries(location.coords);
  }, [findNearby, loadWineries, location]);

  const toggleSavedWine = useCallback((wine: Wine) => {
    setSavedWineIds((prev) => {
      const exists = prev.includes(wine.id);
      const next = exists
        ? prev.filter((id) => id !== wine.id)
        : [...prev, wine.id];
      AsyncStorage.setItem(SAVED_KEY, JSON.stringify(next)).catch(() => undefined);
      return next;
    });
  }, []);

  const isWineSaved = useCallback(
    (id: string) => savedWineIds.includes(id),
    [savedWineIds],
  );

  const value = useMemo<AppContextValue>(
    () => ({
      location,
      wineries,
      fromFallback,
      statusMessage,
      loadingLocation,
      loadingWineries,
      savedWineIds,
      findNearby,
      refreshWineries,
      toggleSavedWine,
      isWineSaved,
      coords: location?.coords ?? null,
    }),
    [
      location,
      wineries,
      fromFallback,
      statusMessage,
      loadingLocation,
      loadingWineries,
      savedWineIds,
      findNearby,
      refreshWineries,
      toggleSavedWine,
      isWineSaved,
    ],
  );

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used within AppProvider');
  return ctx;
}
