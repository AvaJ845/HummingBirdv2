import { Ionicons } from '@expo/vector-icons';
import { RouteProp, useNavigation, useRoute } from '@react-navigation/native';
import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import React from 'react';
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
import { getWineById } from '../data/wines';
import { RootStackParamList } from '../navigation/types';
import { colors } from '../theme/colors';

export function WineDetailScreen() {
  const navigation = useNavigation();
  const route = useRoute<RouteProp<RootStackParamList, 'WineDetail'>>();
  const wine = getWineById(route.params.id);
  const { toggleSavedWine, isWineSaved } = useApp();

  if (!wine) {
    return (
      <SafeAreaView style={styles.safe}>
        <Text style={styles.missing}>Wine not found.</Text>
      </SafeAreaView>
    );
  }

  const saved = isWineSaved(wine.id);

  return (
    <View style={styles.root}>
      <LinearGradient
        colors={[wine.color, colors.burgundyDeep]}
        style={styles.hero}
      >
        <SafeAreaView edges={['top']}>
          <View style={styles.heroBar}>
            <Pressable style={styles.iconBtn} onPress={() => navigation.goBack()}>
              <Ionicons name="chevron-back" size={22} color={colors.white} />
            </Pressable>
            <Pressable
              style={styles.iconBtn}
              onPress={() => {
                Haptics.notificationAsync(
                  Haptics.NotificationFeedbackType.Success,
                ).catch(() => undefined);
                toggleSavedWine(wine);
              }}
            >
              <Ionicons
                name={saved ? 'heart' : 'heart-outline'}
                size={22}
                color={saved ? colors.goldSoft : colors.white}
              />
            </Pressable>
          </View>
          <View style={styles.bottleArt}>
            <View style={[styles.bottle, { backgroundColor: wine.color }]}>
              <View style={styles.neck} />
              <Text style={styles.bottleType}>{wine.type.toUpperCase()}</Text>
            </View>
          </View>
        </SafeAreaView>
      </LinearGradient>

      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.winery}>{wine.winery}</Text>
        <Text style={styles.name}>
          {wine.name}
          {wine.vintage ? ` ${wine.vintage}` : ''}
        </Text>
        <Text style={styles.region}>
          {wine.region}, {wine.country}
        </Text>

        <View style={styles.stats}>
          <RatingBadge rating={wine.rating} count={wine.ratingsCount} />
          <View style={styles.statPill}>
            <Text style={styles.statLabel}>Est. price</Text>
            <Text style={styles.statValue}>${wine.priceEstimate}</Text>
          </View>
          {wine.alcohol != null ? (
            <View style={styles.statPill}>
              <Text style={styles.statLabel}>ABV</Text>
              <Text style={styles.statValue}>{wine.alcohol}%</Text>
            </View>
          ) : null}
        </View>

        <Text style={styles.sectionTitle}>Why you’ll like it</Text>
        <Text style={styles.body}>{wine.description}</Text>

        <Text style={styles.sectionTitle}>Tasting notes</Text>
        <View style={styles.chips}>
          {wine.tastingNotes.map((note) => (
            <View key={note} style={styles.chip}>
              <Text style={styles.chipText}>{note}</Text>
            </View>
          ))}
        </View>

        <Text style={styles.sectionTitle}>Grapes</Text>
        <Text style={styles.body}>{wine.grapes.join(' · ')}</Text>

        <Pressable
          style={styles.cta}
          onPress={() => {
            Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium).catch(
              () => undefined,
            );
            toggleSavedWine(wine);
          }}
        >
          <Ionicons
            name={saved ? 'heart' : 'heart-outline'}
            size={18}
            color={colors.white}
          />
          <Text style={styles.ctaText}>
            {saved ? 'Saved on this device' : 'Save with one tap'}
          </Text>
        </Pressable>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: colors.cream,
  },
  safe: {
    flex: 1,
    backgroundColor: colors.cream,
    alignItems: 'center',
    justifyContent: 'center',
  },
  missing: {
    color: colors.muted,
  },
  hero: {
    paddingBottom: 24,
  },
  heroBar: {
    paddingHorizontal: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  iconBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(0,0,0,0.2)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  bottleArt: {
    alignItems: 'center',
    marginTop: 12,
  },
  bottle: {
    width: 90,
    height: 150,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'flex-end',
    paddingBottom: 16,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.25)',
  },
  neck: {
    position: 'absolute',
    top: -10,
    width: 24,
    height: 18,
    borderTopLeftRadius: 8,
    borderTopRightRadius: 8,
    backgroundColor: 'rgba(255,255,255,0.25)',
  },
  bottleType: {
    color: colors.white,
    fontWeight: '800',
    letterSpacing: 1,
    fontSize: 12,
  },
  content: {
    padding: 20,
    paddingBottom: 40,
    marginTop: -12,
    backgroundColor: colors.cream,
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
  },
  winery: {
    color: colors.burgundySoft,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 0.8,
    fontSize: 12,
  },
  name: {
    marginTop: 6,
    color: colors.ink,
    fontSize: 28,
    fontWeight: '800',
    letterSpacing: -0.5,
  },
  region: {
    marginTop: 4,
    color: colors.muted,
    fontSize: 15,
  },
  stats: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 16,
    marginBottom: 20,
  },
  statPill: {
    backgroundColor: colors.parchment,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 6,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  statLabel: {
    color: colors.muted,
    fontSize: 12,
  },
  statValue: {
    color: colors.ink,
    fontWeight: '800',
  },
  sectionTitle: {
    marginTop: 8,
    marginBottom: 8,
    color: colors.ink,
    fontSize: 18,
    fontWeight: '800',
  },
  body: {
    color: colors.inkSoft,
    lineHeight: 22,
    fontSize: 15,
    marginBottom: 8,
  },
  chips: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 8,
  },
  chip: {
    backgroundColor: colors.creamDark,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 999,
  },
  chipText: {
    color: colors.ink,
    fontWeight: '600',
  },
  cta: {
    marginTop: 24,
    backgroundColor: colors.burgundy,
    borderRadius: 18,
    paddingVertical: 16,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    gap: 8,
  },
  ctaText: {
    color: colors.white,
    fontWeight: '800',
    fontSize: 16,
  },
});
