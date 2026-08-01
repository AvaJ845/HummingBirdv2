import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { colors } from '../theme/colors';

type Props = {
  rating: number;
  count?: number;
  compact?: boolean;
};

export function RatingBadge({ rating, count, compact }: Props) {
  return (
    <View style={[styles.wrap, compact && styles.compact]}>
      <Ionicons name="star" size={compact ? 12 : 14} color={colors.gold} />
      <Text style={[styles.rating, compact && styles.ratingCompact]}>
        {rating.toFixed(1)}
      </Text>
      {count != null ? (
        <Text style={[styles.count, compact && styles.countCompact]}>
          ({count.toLocaleString()})
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: colors.creamDark,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 999,
  },
  compact: {
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  rating: {
    color: colors.ink,
    fontWeight: '700',
    fontSize: 13,
  },
  ratingCompact: {
    fontSize: 12,
  },
  count: {
    color: colors.muted,
    fontSize: 12,
  },
  countCompact: {
    fontSize: 11,
  },
});
