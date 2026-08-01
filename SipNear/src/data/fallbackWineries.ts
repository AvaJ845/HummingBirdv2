import { Coordinates, Winery } from '../types';

/** Curated fallback when Overpass is unavailable or the area has sparse OSM data. */
export const CURATED_WINERIES: Winery[] = [
  {
    id: 'c1',
    name: 'Castello di Amorosa',
    latitude: 38.5645,
    longitude: -122.5427,
    address: '4045 St Helena Hwy, Calistoga, CA',
    website: 'https://castellodiamorosa.com',
    category: 'winery',
    rating: 4.6,
    reviewCount: 8200,
    description: 'A striking Tuscan castle winery with hillside tastings.',
    source: 'curated',
  },
  {
    id: 'c2',
    name: 'Sterling Vineyards',
    latitude: 38.5821,
    longitude: -122.5663,
    address: '1111 Dunaweal Ln, Calistoga, CA',
    category: 'winery',
    rating: 4.4,
    reviewCount: 5400,
    description: 'Aerial tram views over Napa with classic estate wines.',
    source: 'curated',
  },
  {
    id: 'c3',
    name: 'V. Sattui Winery',
    latitude: 38.5012,
    longitude: -122.4589,
    address: '1111 White Ln, St Helena, CA',
    category: 'winery',
    rating: 4.5,
    reviewCount: 9100,
    description: 'Picnic-perfect winery with a bustling tasting marketplace.',
    source: 'curated',
  },
  {
    id: 'c4',
    name: 'Beringer Vineyards',
    latitude: 38.5104,
    longitude: -122.4805,
    address: '2000 Main St, St Helena, CA',
    category: 'vineyard',
    rating: 4.3,
    reviewCount: 12000,
    description: 'Historic Napa landmark with gardens and reserve tastings.',
    source: 'curated',
  },
  {
    id: 'c5',
    name: 'Domaine Carneros',
    latitude: 38.2488,
    longitude: -122.3311,
    address: '1240 Duhig Rd, Napa, CA',
    category: 'winery',
    rating: 4.6,
    reviewCount: 7800,
    description: 'Elegant château known for sparkling wine and terrace views.',
    source: 'curated',
  },
  {
    id: 'c6',
    name: 'Duckhorn Vineyards',
    latitude: 38.5248,
    longitude: -122.4792,
    address: '1000 Lodi Ln, St Helena, CA',
    category: 'winery',
    rating: 4.5,
    reviewCount: 4300,
    description: 'Merlot specialists with a polished tasting salon.',
    source: 'curated',
  },
  {
    id: 'c7',
    name: 'Jordan Vineyard & Winery',
    latitude: 38.7172,
    longitude: -122.8874,
    address: '1474 Alexander Valley Rd, Healdsburg, CA',
    category: 'winery',
    rating: 4.7,
    reviewCount: 3900,
    description: 'Alexander Valley estate famous for Cabernet and hospitality.',
    source: 'curated',
  },
  {
    id: 'c8',
    name: 'Francis Ford Coppola Winery',
    latitude: 38.6741,
    longitude: -122.8879,
    address: '300 Via Archimedes, Geyserville, CA',
    category: 'winery',
    rating: 4.4,
    reviewCount: 10200,
    description: 'Movie memorabilia, poolside lounging, and approachable wines.',
    source: 'curated',
  },
];

export function haversineMeters(
  a: Coordinates,
  b: Coordinates,
): number {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const R = 6371000;
  const dLat = toRad(b.latitude - a.latitude);
  const dLon = toRad(b.longitude - a.longitude);
  const lat1 = toRad(a.latitude);
  const lat2 = toRad(b.latitude);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

export function withDistances(
  wineries: Winery[],
  origin: Coordinates,
): Winery[] {
  return wineries
    .map((winery) => ({
      ...winery,
      distanceMeters: haversineMeters(origin, {
        latitude: winery.latitude,
        longitude: winery.longitude,
      }),
    }))
    .sort((a, b) => (a.distanceMeters ?? 0) - (b.distanceMeters ?? 0));
}

export function nearbyCurated(
  origin: Coordinates,
  radiusMeters = 80000,
): Winery[] {
  return withDistances(CURATED_WINERIES, origin).filter(
    (w) => (w.distanceMeters ?? Infinity) <= radiusMeters,
  );
}
