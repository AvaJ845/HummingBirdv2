import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import React, { useMemo, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import MapView, { Marker, PROVIDER_DEFAULT } from 'react-native-maps';
import { SafeAreaView } from 'react-native-safe-area-context';
import { EasyButton } from '../components/EasyButton';
import { WineryCard } from '../components/WineryCard';
import { useApp } from '../context/AppContext';
import { DEFAULT_LOCATION } from '../services/location';
import { RootStackParamList } from '../navigation/types';
import { colors } from '../theme/colors';

export function NearbyScreen() {
  const navigation =
    useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const {
    wineries,
    location,
    findNearby,
    refreshWineries,
    loadingLocation,
    loadingWineries,
    statusMessage,
    fromFallback,
  } = useApp();
  const [showMap, setShowMap] = useState(Platform.OS !== 'web');
  const busy = loadingLocation || loadingWineries;
  const coords = location?.coords ?? DEFAULT_LOCATION;

  const region = useMemo(
    () => ({
      latitude: coords.latitude,
      longitude: coords.longitude,
      latitudeDelta: 0.18,
      longitudeDelta: 0.18,
    }),
    [coords.latitude, coords.longitude],
  );

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <View style={{ flex: 1 }}>
          <Text style={styles.title}>Nearby</Text>
          <Text style={styles.subtitle}>
            {location?.label ?? 'Tap to pull your location'}
            {fromFallback ? ' · curated backup' : ''}
          </Text>
        </View>
        <Pressable
          style={styles.toggle}
          onPress={() => setShowMap((v) => !v)}
        >
          <Ionicons
            name={showMap ? 'list' : 'map'}
            size={16}
            color={colors.burgundy}
          />
          <Text style={styles.toggleText}>{showMap ? 'List' : 'Map'}</Text>
        </Pressable>
      </View>

      {!wineries.length ? (
        <View style={styles.emptyWrap}>
          <EasyButton
            title="Find Wineries Near Me"
            subtitle="One tap · no account"
            loading={busy}
            onPress={findNearby}
          />
        </View>
      ) : (
        <>
          {showMap && Platform.OS !== 'web' ? (
            <View style={styles.mapWrap}>
              <MapView
                style={StyleSheet.absoluteFill}
                provider={PROVIDER_DEFAULT}
                initialRegion={region}
                region={region}
              >
                <Marker
                  coordinate={coords}
                  title="You"
                  pinColor={colors.gold}
                />
                {wineries.map((winery) => (
                  <Marker
                    key={winery.id}
                    coordinate={{
                      latitude: winery.latitude,
                      longitude: winery.longitude,
                    }}
                    title={winery.name}
                    description={winery.address}
                    pinColor={colors.burgundy}
                    onCalloutPress={() =>
                      navigation.navigate('WineryDetail', { id: winery.id })
                    }
                  />
                ))}
              </MapView>
            </View>
          ) : null}

          {showMap && Platform.OS === 'web' ? (
            <View style={styles.webMapNotice}>
              <Ionicons name="map-outline" size={22} color={colors.burgundy} />
              <Text style={styles.webMapTitle}>Map view shines on iOS</Text>
              <Text style={styles.webMapText}>
                Open SipNear in Expo Go / iOS Simulator for the native map.
                Your nearby list below is ready either way.
              </Text>
            </View>
          ) : null}

          {statusMessage ? (
            <Text style={styles.banner}>{statusMessage}</Text>
          ) : null}

          <View style={styles.listHeader}>
            <Text style={styles.count}>{wineries.length} places</Text>
            <Pressable onPress={refreshWineries} disabled={busy} hitSlop={8}>
              {busy ? (
                <ActivityIndicator color={colors.burgundy} />
              ) : (
                <Text style={styles.refresh}>Refresh</Text>
              )}
            </Pressable>
          </View>

          <FlatList
            data={wineries}
            keyExtractor={(item) => item.id}
            contentContainerStyle={styles.list}
            ItemSeparatorComponent={() => <View style={{ height: 10 }} />}
            renderItem={({ item }) => (
              <WineryCard
                winery={item}
                onPress={() =>
                  navigation.navigate('WineryDetail', { id: item.id })
                }
              />
            )}
          />
        </>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: colors.cream,
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 8,
    paddingBottom: 12,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  title: {
    fontSize: 30,
    fontWeight: '800',
    color: colors.ink,
    letterSpacing: -0.6,
  },
  subtitle: {
    color: colors.muted,
    marginTop: 2,
  },
  toggle: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: colors.parchment,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 999,
  },
  toggleText: {
    color: colors.burgundy,
    fontWeight: '700',
  },
  emptyWrap: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
  },
  mapWrap: {
    height: 240,
    marginHorizontal: 20,
    borderRadius: 24,
    overflow: 'hidden',
    marginBottom: 12,
    borderWidth: 1,
    borderColor: colors.border,
  },
  webMapNotice: {
    marginHorizontal: 20,
    marginBottom: 12,
    backgroundColor: colors.parchment,
    borderRadius: 20,
    padding: 16,
    gap: 6,
    borderWidth: 1,
    borderColor: colors.border,
  },
  webMapTitle: {
    color: colors.ink,
    fontWeight: '800',
  },
  webMapText: {
    color: colors.muted,
    lineHeight: 20,
  },
  banner: {
    marginHorizontal: 20,
    marginBottom: 8,
    color: colors.burgundySoft,
    fontSize: 13,
  },
  listHeader: {
    paddingHorizontal: 20,
    paddingBottom: 8,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  count: {
    color: colors.inkSoft,
    fontWeight: '700',
  },
  refresh: {
    color: colors.burgundy,
    fontWeight: '700',
  },
  list: {
    paddingHorizontal: 20,
    paddingBottom: 32,
  },
});
