import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import React, { useMemo } from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { WineCard } from '../components/WineCard';
import { useApp } from '../context/AppContext';
import { WINES } from '../data/wines';
import { RootStackParamList } from '../navigation/types';
import { colors } from '../theme/colors';

export function SavedScreen() {
  const navigation =
    useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const { savedWineIds, isWineSaved } = useApp();

  const wines = useMemo(
    () => WINES.filter((wine) => savedWineIds.includes(wine.id)),
    [savedWineIds],
  );

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <Pressable style={styles.back} onPress={() => navigation.goBack()}>
          <Ionicons name="chevron-back" size={22} color={colors.ink} />
        </Pressable>
        <View style={{ flex: 1 }}>
          <Text style={styles.title}>Saved</Text>
          <Text style={styles.subtitle}>Kept on this device · no account</Text>
        </View>
      </View>

      {wines.length === 0 ? (
        <View style={styles.empty}>
          <Ionicons name="heart-outline" size={36} color={colors.burgundySoft} />
          <Text style={styles.emptyTitle}>Nothing saved yet</Text>
          <Text style={styles.emptyText}>
            Tap the heart on any bottle — it stays on your phone, no signup.
          </Text>
        </View>
      ) : (
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
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingHorizontal: 16,
    paddingBottom: 12,
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
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: colors.ink,
  },
  subtitle: {
    color: colors.muted,
  },
  list: {
    padding: 20,
    paddingBottom: 40,
  },
  empty: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 32,
    gap: 8,
  },
  emptyTitle: {
    color: colors.ink,
    fontWeight: '800',
    fontSize: 18,
  },
  emptyText: {
    color: colors.muted,
    textAlign: 'center',
    lineHeight: 21,
  },
});
