import { Ionicons } from '@expo/vector-icons';
import { RouteProp, useNavigation, useRoute } from '@react-navigation/native';
import * as Linking from 'expo-linking';
import React, { useMemo } from 'react';
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { RatingBadge } from '../components/RatingBadge';
import { useApp } from '../context/AppContext';
import { CURATED_WINERIES } from '../data/fallbackWineries';
import { formatDistance } from '../services/location';
import { categoryLabel } from '../services/wineries';
import { RootStackParamList } from '../navigation/types';
import { colors } from '../theme/colors';

export function WineryDetailScreen() {
  const navigation = useNavigation();
  const route = useRoute<RouteProp<RootStackParamList, 'WineryDetail'>>();
  const { wineries } = useApp();

  const winery = useMemo(() => {
    return (
      wineries.find((w) => w.id === route.params.id) ||
      CURATED_WINERIES.find((w) => w.id === route.params.id)
    );
  }, [route.params.id, wineries]);

  if (!winery) {
    return (
      <SafeAreaView style={styles.safe}>
        <Text style={styles.missing}>Winery not found.</Text>
      </SafeAreaView>
    );
  }

  const mapsUrl = `https://www.google.com/maps/dir/?api=1&destination=${winery.latitude},${winery.longitude}`;

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.topBar}>
        <Pressable style={styles.back} onPress={() => navigation.goBack()}>
          <Ionicons name="chevron-back" size={22} color={colors.ink} />
        </Pressable>
        <Text style={styles.topTitle}>Winery</Text>
        <View style={{ width: 40 }} />
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.heroCard}>
          <View style={styles.icon}>
            <Ionicons name="wine" size={28} color={colors.burgundy} />
          </View>
          <Text style={styles.name}>{winery.name}</Text>
          <Text style={styles.meta}>
            {categoryLabel(winery.category)}
            {winery.distanceMeters != null
              ? ` · ${formatDistance(winery.distanceMeters)} away`
              : ''}
          </Text>
          {winery.rating != null ? (
            <View style={{ marginTop: 10 }}>
              <RatingBadge rating={winery.rating} count={winery.reviewCount} />
            </View>
          ) : null}
        </View>

        {winery.description ? (
          <>
            <Text style={styles.section}>About</Text>
            <Text style={styles.body}>{winery.description}</Text>
          </>
        ) : (
          <>
            <Text style={styles.section}>About</Text>
            <Text style={styles.body}>
              {winery.source === 'osm'
                ? 'Pulled live from OpenStreetMap near your location. Tap directions for an easy route.'
                : 'A curated wine-country highlight shown when live map data is sparse nearby.'}
            </Text>
          </>
        )}

        {winery.address ? (
          <>
            <Text style={styles.section}>Address</Text>
            <Text style={styles.body}>{winery.address}</Text>
          </>
        ) : null}

        {winery.hours ? (
          <>
            <Text style={styles.section}>Hours</Text>
            <Text style={styles.body}>{winery.hours}</Text>
          </>
        ) : null}

        <View style={styles.actions}>
          <Pressable
            style={styles.primary}
            onPress={() => Linking.openURL(mapsUrl)}
          >
            <Ionicons name="navigate" size={18} color={colors.white} />
            <Text style={styles.primaryText}>Directions</Text>
          </Pressable>

          {winery.website ? (
            <Pressable
              style={styles.secondary}
              onPress={() => Linking.openURL(winery.website!)}
            >
              <Ionicons name="globe-outline" size={18} color={colors.burgundy} />
              <Text style={styles.secondaryText}>Website</Text>
            </Pressable>
          ) : null}

          {winery.phone ? (
            <Pressable
              style={styles.secondary}
              onPress={() => Linking.openURL(`tel:${winery.phone}`)}
            >
              <Ionicons name="call-outline" size={18} color={colors.burgundy} />
              <Text style={styles.secondaryText}>Call</Text>
            </Pressable>
          ) : null}
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
  missing: {
    marginTop: 40,
    textAlign: 'center',
    color: colors.muted,
  },
  topBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingBottom: 8,
  },
  back: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: colors.parchment,
    borderWidth: 1,
    borderColor: colors.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
  topTitle: {
    color: colors.ink,
    fontWeight: '800',
    fontSize: 16,
  },
  content: {
    padding: 20,
    paddingBottom: 40,
  },
  heroCard: {
    backgroundColor: colors.parchment,
    borderRadius: 28,
    padding: 22,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.border,
    marginBottom: 20,
  },
  icon: {
    width: 64,
    height: 64,
    borderRadius: 22,
    backgroundColor: colors.creamDark,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  name: {
    color: colors.ink,
    fontSize: 26,
    fontWeight: '800',
    textAlign: 'center',
    letterSpacing: -0.4,
  },
  meta: {
    marginTop: 6,
    color: colors.muted,
    textAlign: 'center',
  },
  section: {
    color: colors.ink,
    fontWeight: '800',
    fontSize: 17,
    marginBottom: 6,
    marginTop: 8,
  },
  body: {
    color: colors.inkSoft,
    lineHeight: 22,
    marginBottom: 8,
  },
  actions: {
    marginTop: 20,
    gap: 10,
  },
  primary: {
    backgroundColor: colors.burgundy,
    borderRadius: 18,
    paddingVertical: 16,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    gap: 8,
  },
  primaryText: {
    color: colors.white,
    fontWeight: '800',
    fontSize: 16,
  },
  secondary: {
    backgroundColor: colors.parchment,
    borderRadius: 18,
    paddingVertical: 14,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    gap: 8,
    borderWidth: 1,
    borderColor: colors.border,
  },
  secondaryText: {
    color: colors.burgundy,
    fontWeight: '800',
    fontSize: 15,
  },
});
