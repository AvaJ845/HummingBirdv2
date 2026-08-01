import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import React from 'react';
import {
  SafeAreaView,
  StyleSheet,
  Text,
  View,
  Pressable,
} from 'react-native';
import { EasyButton } from '../components/EasyButton';
import { useApp } from '../context/AppContext';
import { colors, gradients } from '../theme/colors';

type Props = {
  onContinue: () => void;
};

export function WelcomeScreen({ onContinue }: Props) {
  const { findNearby, loadingLocation, loadingWineries } = useApp();
  const busy = loadingLocation || loadingWineries;

  return (
    <LinearGradient colors={[...gradients.hero]} style={styles.root}>
      <SafeAreaView style={styles.safe}>
        <View style={styles.badge}>
          <Ionicons name="sparkles" size={14} color={colors.goldSoft} />
          <Text style={styles.badgeText}>No account · One tap</Text>
        </View>

        <View style={styles.heroCopy}>
          <Text style={styles.kicker}>SIPNEAR</Text>
          <Text style={styles.title}>Wine discovery,{'\n'}made easy.</Text>
          <Text style={styles.subtitle}>
            Find wineries around you, browse top-rated bottles, and skip the
            signup wall. Vivino vibes — easier buttons.
          </Text>
        </View>

        <View style={styles.features}>
          {[
            { icon: 'locate' as const, label: 'Pull nearby wineries from your location' },
            { icon: 'wine' as const, label: 'Browse ratings & tasting notes instantly' },
            { icon: 'heart' as const, label: 'Save favorites on-device — no login' },
          ].map((item) => (
            <View key={item.label} style={styles.featureRow}>
              <View style={styles.featureIcon}>
                <Ionicons name={item.icon} size={16} color={colors.goldSoft} />
              </View>
              <Text style={styles.featureText}>{item.label}</Text>
            </View>
          ))}
        </View>

        <View style={styles.cta}>
          <EasyButton
            title="Find Wineries Near Me"
            subtitle="Uses your location · no account needed"
            icon="navigate"
            loading={busy}
            onPress={async () => {
              await findNearby();
              onContinue();
            }}
          />
          <Pressable
            onPress={onContinue}
            style={styles.secondary}
            hitSlop={10}
          >
            <Text style={styles.secondaryText}>Browse wines first</Text>
          </Pressable>
        </View>
      </SafeAreaView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
  },
  safe: {
    flex: 1,
    paddingHorizontal: 24,
    paddingTop: 18,
    paddingBottom: 28,
    justifyContent: 'space-between',
  },
  badge: {
    alignSelf: 'flex-start',
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: 'rgba(255,255,255,0.12)',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 999,
  },
  badgeText: {
    color: colors.goldSoft,
    fontWeight: '700',
    fontSize: 12,
    letterSpacing: 0.3,
  },
  heroCopy: {
    gap: 12,
    marginTop: 24,
  },
  kicker: {
    color: colors.goldSoft,
    fontWeight: '800',
    letterSpacing: 3,
    fontSize: 13,
  },
  title: {
    color: colors.white,
    fontSize: 40,
    fontWeight: '800',
    lineHeight: 46,
    letterSpacing: -1,
  },
  subtitle: {
    color: 'rgba(255,255,255,0.82)',
    fontSize: 16,
    lineHeight: 24,
    maxWidth: 340,
  },
  features: {
    gap: 12,
    marginVertical: 28,
  },
  featureRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  featureIcon: {
    width: 34,
    height: 34,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.1)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  featureText: {
    color: 'rgba(255,255,255,0.9)',
    fontSize: 14,
    flex: 1,
  },
  cta: {
    gap: 14,
  },
  secondary: {
    alignItems: 'center',
    paddingVertical: 8,
  },
  secondaryText: {
    color: 'rgba(255,255,255,0.78)',
    fontWeight: '600',
    fontSize: 15,
  },
});
