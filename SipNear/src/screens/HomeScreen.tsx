import { Ionicons } from '@expo/vector-icons';
import { CompositeNavigationProp, useNavigation } from '@react-navigation/native';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import React, { useMemo } from 'react';
import {
  ActivityIndicator,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { EasyButton } from '../components/EasyButton';
import { SectionHeader } from '../components/SectionHeader';
import { WineCard } from '../components/WineCard';
import { WineryCard } from '../components/WineryCard';
import { useApp } from '../context/AppContext';
import { getTopRatedWines } from '../data/wines';
import { MainTabParamList, RootStackParamList } from '../navigation/types';
import { colors } from '../theme/colors';

type Nav = CompositeNavigationProp<
  BottomTabNavigationProp<MainTabParamList, 'Home'>,
  NativeStackNavigationProp<RootStackParamList>
>;

export function HomeScreen() {
  const navigation = useNavigation<Nav>();
  const {
    findNearby,
    wineries,
    location,
    loadingLocation,
    loadingWineries,
    isWineSaved,
    statusMessage,
  } = useApp();

  const topWines = useMemo(() => getTopRatedWines(6), []);
  const nearbyPreview = wineries.slice(0, 4);
  const busy = loadingLocation || loadingWineries;

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <ScrollView
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <View>
            <Text style={styles.kicker}>Good sipping</Text>
            <Text style={styles.title}>SipNear</Text>
          </View>
          <Pressable
            style={styles.pill}
            onPress={() => navigation.navigate('Saved')}
          >
            <Ionicons name="heart" size={16} color={colors.wine} />
            <Text style={styles.pillText}>Saved</Text>
          </Pressable>
        </View>

        <Text style={styles.lede}>
          One easy button. No account. Wineries around you + wines worth drinking.
        </Text>

        <EasyButton
          title={wineries.length ? 'Refresh Nearby Wineries' : 'Find Wineries Near Me'}
          subtitle={
            location
              ? location.usingFallback
                ? 'Using demo wine country · tap to try your location'
                : location.label
              : 'Pull your location · instant results'
          }
          icon="navigate"
          loading={busy}
          onPress={findNearby}
          style={styles.easy}
        />

        <View style={styles.quickRow}>
          {[
            { label: 'Reds', type: 'red' as const, icon: 'wine' as const },
            { label: 'Whites', type: 'white' as const, icon: 'water' as const },
            { label: 'Bubbles', type: 'sparkling' as const, icon: 'sparkles' as const },
            { label: 'Rosé', type: 'rose' as const, icon: 'flower' as const },
          ].map((item) => (
            <Pressable
              key={item.label}
              style={styles.quickChip}
              onPress={() =>
                navigation.navigate('Discover', { filter: item.type })
              }
            >
              <Ionicons name={item.icon} size={16} color={colors.burgundy} />
              <Text style={styles.quickText}>{item.label}</Text>
            </Pressable>
          ))}
        </View>

        <View style={styles.section}>
          <SectionHeader
            title="Nearby wineries"
            subtitle={
              statusMessage ||
              (nearbyPreview.length
                ? `${wineries.length} spots found`
                : 'Tap the easy button to pull locations')
            }
            actionLabel="Map"
            onAction={() => navigation.navigate('Nearby')}
          />
          {busy && !nearbyPreview.length ? (
            <View style={styles.loadingBox}>
              <ActivityIndicator color={colors.burgundy} />
              <Text style={styles.loadingText}>Finding wineries around you…</Text>
            </View>
          ) : nearbyPreview.length ? (
            <View style={styles.list}>
              {nearbyPreview.map((winery) => (
                <WineryCard
                  key={winery.id}
                  winery={winery}
                  onPress={() =>
                    navigation.navigate('WineryDetail', { id: winery.id })
                  }
                />
              ))}
            </View>
          ) : (
            <View style={styles.emptyBox}>
              <Ionicons name="map-outline" size={28} color={colors.burgundySoft} />
              <Text style={styles.emptyTitle}>Ready when you are</Text>
              <Text style={styles.emptyText}>
                Hit the big button — we’ll use your location to surface wineries,
                tasting rooms, and wine shops nearby.
              </Text>
            </View>
          )}
        </View>

        <View style={styles.section}>
          <SectionHeader
            title="Top-rated bottles"
            subtitle="Vivino-style ratings, zero friction"
            actionLabel="See all"
            onAction={() => navigation.navigate('Discover')}
          />
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.horizontal}
          >
            {topWines.map((wine) => (
              <WineCard
                key={wine.id}
                wine={wine}
                horizontal
                saved={isWineSaved(wine.id)}
                onPress={() => navigation.navigate('WineDetail', { id: wine.id })}
              />
            ))}
          </ScrollView>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: colors.cream,
  },
  content: {
    padding: 20,
    paddingBottom: 40,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  kicker: {
    color: colors.muted,
    fontSize: 13,
    fontWeight: '600',
  },
  title: {
    color: colors.ink,
    fontSize: 32,
    fontWeight: '800',
    letterSpacing: -0.8,
  },
  pill: {
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
  pillText: {
    color: colors.inkSoft,
    fontWeight: '700',
  },
  lede: {
    marginTop: 10,
    marginBottom: 18,
    color: colors.inkSoft,
    fontSize: 15,
    lineHeight: 22,
  },
  easy: {
    marginBottom: 16,
  },
  quickRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 28,
  },
  quickChip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: colors.parchment,
    borderColor: colors.border,
    borderWidth: 1,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 999,
  },
  quickText: {
    color: colors.ink,
    fontWeight: '700',
    fontSize: 13,
  },
  section: {
    marginBottom: 28,
  },
  list: {
    gap: 10,
  },
  horizontal: {
    gap: 12,
    paddingRight: 8,
  },
  loadingBox: {
    backgroundColor: colors.parchment,
    borderRadius: 20,
    padding: 24,
    alignItems: 'center',
    gap: 10,
    borderWidth: 1,
    borderColor: colors.border,
  },
  loadingText: {
    color: colors.muted,
  },
  emptyBox: {
    backgroundColor: colors.parchment,
    borderRadius: 20,
    padding: 22,
    gap: 8,
    borderWidth: 1,
    borderColor: colors.border,
  },
  emptyTitle: {
    color: colors.ink,
    fontWeight: '800',
    fontSize: 16,
  },
  emptyText: {
    color: colors.muted,
    lineHeight: 20,
  },
});
