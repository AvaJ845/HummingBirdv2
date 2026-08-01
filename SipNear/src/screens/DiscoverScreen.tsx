import { RouteProp, useNavigation, useRoute } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import React, { useEffect, useMemo, useState } from 'react';
import {
  FlatList,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { WineCard } from '../components/WineCard';
import { useApp } from '../context/AppContext';
import { WINES } from '../data/wines';
import { RootStackParamList, MainTabParamList } from '../navigation/types';
import { WineType } from '../types';
import { colors } from '../theme/colors';

const FILTERS: { label: string; value: WineType | 'all' }[] = [
  { label: 'All', value: 'all' },
  { label: 'Red', value: 'red' },
  { label: 'White', value: 'white' },
  { label: 'Rosé', value: 'rose' },
  { label: 'Sparkling', value: 'sparkling' },
  { label: 'Dessert', value: 'dessert' },
];

export function DiscoverScreen() {
  const navigation =
    useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const route = useRoute<RouteProp<MainTabParamList, 'Discover'>>();
  const [filter, setFilter] = useState<WineType | 'all'>(
    route.params?.filter ?? 'all',
  );
  const { isWineSaved } = useApp();

  useEffect(() => {
    if (route.params?.filter) {
      setFilter(route.params.filter);
    }
  }, [route.params?.filter]);

  const wines = useMemo(() => {
    const list =
      filter === 'all' ? WINES : WINES.filter((wine) => wine.type === filter);
    return [...list].sort((a, b) => b.rating - a.rating);
  }, [filter]);

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.title}>Discover</Text>
        <Text style={styles.subtitle}>
          Browse like Vivino — tap any bottle for notes & ratings.
        </Text>
      </View>

      <View style={styles.filters}>
        {FILTERS.map((item) => {
          const active = filter === item.value;
          return (
            <Pressable
              key={item.value}
              onPress={() => setFilter(item.value)}
              style={[styles.chip, active && styles.chipActive]}
            >
              <Text style={[styles.chipText, active && styles.chipTextActive]}>
                {item.label}
              </Text>
            </Pressable>
          );
        })}
      </View>

      <FlatList
        data={wines}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ItemSeparatorComponent={() => <View style={{ height: 12 }} />}
        renderItem={({ item }) => (
          <WineCard
            wine={item}
            saved={isWineSaved(item.id)}
            onPress={() => navigation.navigate('WineDetail', { id: item.id })}
          />
        )}
      />
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
    paddingBottom: 8,
  },
  title: {
    fontSize: 30,
    fontWeight: '800',
    color: colors.ink,
    letterSpacing: -0.6,
  },
  subtitle: {
    color: colors.muted,
    marginTop: 4,
    lineHeight: 20,
  },
  filters: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  chip: {
    backgroundColor: colors.parchment,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 999,
  },
  chipActive: {
    backgroundColor: colors.burgundy,
    borderColor: colors.burgundy,
  },
  chipText: {
    color: colors.inkSoft,
    fontWeight: '700',
    fontSize: 13,
  },
  chipTextActive: {
    color: colors.white,
  },
  list: {
    paddingHorizontal: 20,
    paddingBottom: 32,
  },
});
