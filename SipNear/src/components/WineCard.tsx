import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { Wine } from '../types';
import { colors } from '../theme/colors';
import { RatingBadge } from './RatingBadge';

type Props = {
  wine: Wine;
  onPress: () => void;
  saved?: boolean;
  horizontal?: boolean;
};

export function WineCard({ wine, onPress, saved, horizontal }: Props) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.card,
        horizontal && styles.horizontal,
        pressed && styles.pressed,
      ]}
    >
      <View style={[styles.bottle, { backgroundColor: wine.color }]}>
        <View style={styles.bottleNeck} />
        <View style={styles.bottleLabel}>
          <Text style={styles.bottleInitial}>{wine.type[0].toUpperCase()}</Text>
        </View>
      </View>
      <View style={styles.body}>
        <Text style={styles.winery} numberOfLines={1}>
          {wine.winery}
        </Text>
        <Text style={styles.name} numberOfLines={2}>
          {wine.name}
          {wine.vintage ? ` ${wine.vintage}` : ''}
        </Text>
        <Text style={styles.meta} numberOfLines={1}>
          {wine.region} · {wine.country}
        </Text>
        <View style={styles.footer}>
          <RatingBadge rating={wine.rating} count={wine.ratingsCount} compact />
          <Text style={styles.price}>~${wine.priceEstimate}</Text>
        </View>
      </View>
      {saved ? (
        <View style={styles.savedMark}>
          <Ionicons name="heart" size={14} color={colors.wine} />
        </View>
      ) : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.parchment,
    borderRadius: 22,
    padding: 14,
    flexDirection: 'row',
    gap: 14,
    borderWidth: 1,
    borderColor: colors.border,
    shadowColor: colors.shadow,
    shadowOpacity: 1,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 6 },
    elevation: 3,
  },
  horizontal: {
    width: 280,
  },
  pressed: {
    opacity: 0.92,
    transform: [{ scale: 0.99 }],
  },
  bottle: {
    width: 54,
    height: 96,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'flex-end',
    paddingBottom: 10,
  },
  bottleNeck: {
    position: 'absolute',
    top: -6,
    width: 16,
    height: 14,
    borderTopLeftRadius: 6,
    borderTopRightRadius: 6,
    backgroundColor: 'rgba(255,255,255,0.25)',
  },
  bottleLabel: {
    width: 34,
    height: 34,
    borderRadius: 8,
    backgroundColor: 'rgba(255,255,255,0.2)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  bottleInitial: {
    color: colors.white,
    fontWeight: '800',
    fontSize: 14,
  },
  body: {
    flex: 1,
    justifyContent: 'center',
    gap: 3,
  },
  winery: {
    color: colors.burgundySoft,
    fontSize: 12,
    fontWeight: '600',
    textTransform: 'uppercase',
    letterSpacing: 0.6,
  },
  name: {
    color: colors.ink,
    fontSize: 16,
    fontWeight: '700',
    lineHeight: 21,
  },
  meta: {
    color: colors.muted,
    fontSize: 13,
  },
  footer: {
    marginTop: 8,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  price: {
    color: colors.inkSoft,
    fontWeight: '700',
    fontSize: 14,
  },
  savedMark: {
    position: 'absolute',
    top: 12,
    right: 12,
  },
});
