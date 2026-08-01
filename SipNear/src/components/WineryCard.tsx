import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { Winery } from '../types';
import { formatDistance } from '../services/location';
import { categoryLabel } from '../services/wineries';
import { colors } from '../theme/colors';
import { RatingBadge } from './RatingBadge';

type Props = {
  winery: Winery;
  onPress: () => void;
};

export function WineryCard({ winery, onPress }: Props) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [styles.card, pressed && styles.pressed]}
    >
      <View style={styles.icon}>
        <Ionicons name="wine" size={22} color={colors.burgundy} />
      </View>
      <View style={styles.body}>
        <View style={styles.topRow}>
          <Text style={styles.name} numberOfLines={1}>
            {winery.name}
          </Text>
          {winery.distanceMeters != null ? (
            <Text style={styles.distance}>{formatDistance(winery.distanceMeters)}</Text>
          ) : null}
        </View>
        <Text style={styles.meta} numberOfLines={1}>
          {categoryLabel(winery.category)}
          {winery.address ? ` · ${winery.address}` : ''}
        </Text>
        {winery.rating != null ? (
          <View style={styles.ratingRow}>
            <RatingBadge
              rating={winery.rating}
              count={winery.reviewCount}
              compact
            />
          </View>
        ) : (
          <Text style={styles.source}>
            {winery.source === 'osm' ? 'OpenStreetMap' : 'Curated pick'}
          </Text>
        )}
      </View>
      <Ionicons name="chevron-forward" size={18} color={colors.muted} />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.parchment,
    borderRadius: 20,
    padding: 14,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    borderWidth: 1,
    borderColor: colors.border,
  },
  pressed: {
    opacity: 0.92,
  },
  icon: {
    width: 46,
    height: 46,
    borderRadius: 16,
    backgroundColor: colors.creamDark,
    alignItems: 'center',
    justifyContent: 'center',
  },
  body: {
    flex: 1,
    gap: 3,
  },
  topRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  name: {
    flex: 1,
    color: colors.ink,
    fontSize: 16,
    fontWeight: '700',
  },
  distance: {
    color: colors.burgundy,
    fontWeight: '700',
    fontSize: 12,
  },
  meta: {
    color: colors.muted,
    fontSize: 13,
  },
  ratingRow: {
    marginTop: 4,
    alignSelf: 'flex-start',
  },
  source: {
    marginTop: 4,
    color: colors.muted,
    fontSize: 12,
  },
});
