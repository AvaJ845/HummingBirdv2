import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import React from 'react';
import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  Text,
  View,
  ViewStyle,
} from 'react-native';
import { colors, gradients } from '../theme/colors';

type Props = {
  title: string;
  subtitle?: string;
  icon?: keyof typeof Ionicons.glyphMap;
  onPress: () => void;
  loading?: boolean;
  style?: ViewStyle;
  size?: 'hero' | 'regular';
};

export function EasyButton({
  title,
  subtitle,
  icon = 'locate',
  onPress,
  loading,
  style,
  size = 'hero',
}: Props) {
  const isHero = size === 'hero';

  return (
    <Pressable
      accessibilityRole="button"
      onPress={() => {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium).catch(() => undefined);
        onPress();
      }}
      style={({ pressed }) => [
        styles.pressable,
        isHero ? styles.hero : styles.regular,
        pressed && styles.pressed,
        style,
      ]}
    >
      <LinearGradient
        colors={[...gradients.easyButton]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={[styles.gradient, isHero ? styles.heroGradient : styles.regularGradient]}
      >
        <View style={styles.iconWrap}>
          {loading ? (
            <ActivityIndicator color={colors.white} />
          ) : (
            <Ionicons name={icon} size={isHero ? 28 : 22} color={colors.white} />
          )}
        </View>
        <View style={styles.copy}>
          <Text style={[styles.title, isHero && styles.titleHero]}>{title}</Text>
          {subtitle ? (
            <Text style={[styles.subtitle, isHero && styles.subtitleHero]}>
              {subtitle}
            </Text>
          ) : null}
        </View>
        <Ionicons
          name="arrow-forward-circle"
          size={isHero ? 30 : 24}
          color={colors.goldSoft}
        />
      </LinearGradient>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  pressable: {
    borderRadius: 28,
    shadowColor: colors.burgundyDeep,
    shadowOpacity: 0.28,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 10 },
    elevation: 8,
  },
  hero: {
    width: '100%',
  },
  regular: {
    width: '100%',
  },
  pressed: {
    transform: [{ scale: 0.985 }],
    opacity: 0.96,
  },
  gradient: {
    borderRadius: 28,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
  },
  heroGradient: {
    paddingVertical: 22,
    paddingHorizontal: 20,
  },
  regularGradient: {
    paddingVertical: 16,
    paddingHorizontal: 16,
  },
  iconWrap: {
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: 'rgba(255,255,255,0.14)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  copy: {
    flex: 1,
  },
  title: {
    color: colors.white,
    fontSize: 17,
    fontWeight: '700',
    letterSpacing: 0.2,
  },
  titleHero: {
    fontSize: 22,
  },
  subtitle: {
    color: 'rgba(255,255,255,0.82)',
    marginTop: 4,
    fontSize: 13,
  },
  subtitleHero: {
    fontSize: 14,
    marginTop: 6,
  },
});
