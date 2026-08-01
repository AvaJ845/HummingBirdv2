import {
  CURATED_WINERIES,
  nearbyCurated,
  withDistances,
} from '../data/fallbackWineries';
import { Coordinates, Winery } from '../types';

const OVERPASS_ENDPOINTS = [
  'https://overpass-api.de/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
];

type OsmElement = {
  id: number;
  type: string;
  lat?: number;
  lon?: number;
  center?: { lat: number; lon: number };
  tags?: Record<string, string>;
};

function categoryFromTags(
  tags: Record<string, string>,
): Winery['category'] {
  if (tags.craft === 'winery' || tags.amenity === 'winery') return 'winery';
  if (tags.landuse === 'vineyard') return 'vineyard';
  if (tags.tourism === 'wine_cellar') return 'wine_cellar';
  if (tags.shop === 'wine' || tags.shop === 'alcohol') return 'wine_shop';
  if (tags.tourism === 'attraction' && /wine|vine/i.test(tags.name ?? '')) {
    return 'tasting_room';
  }
  return 'winery';
}

function buildAddress(tags: Record<string, string>): string | undefined {
  const parts = [
    tags['addr:housenumber'],
    tags['addr:street'],
    tags['addr:city'],
    tags['addr:state'],
  ].filter(Boolean);
  return parts.length ? parts.join(' ') : tags['addr:full'];
}

function mapElement(el: OsmElement): Winery | null {
  const tags = el.tags ?? {};
  const name = tags.name?.trim();
  if (!name) return null;

  const latitude = el.lat ?? el.center?.lat;
  const longitude = el.lon ?? el.center?.lon;
  if (latitude == null || longitude == null) return null;

  return {
    id: `osm-${el.type}-${el.id}`,
    name,
    latitude,
    longitude,
    address: buildAddress(tags),
    phone: tags.phone || tags['contact:phone'],
    website: tags.website || tags['contact:website'],
    hours: tags.opening_hours,
    category: categoryFromTags(tags),
    description: tags.description,
    source: 'osm',
  };
}

function buildQuery(coords: Coordinates, radiusMeters: number): string {
  const { latitude, longitude } = coords;
  return `
[out:json][timeout:25];
(
  nwr["craft"="winery"](around:${radiusMeters},${latitude},${longitude});
  nwr["amenity"="winery"](around:${radiusMeters},${latitude},${longitude});
  nwr["tourism"="wine_cellar"](around:${radiusMeters},${latitude},${longitude});
  nwr["shop"="wine"](around:${radiusMeters},${latitude},${longitude});
  nwr["landuse"="vineyard"]["name"](around:${radiusMeters},${latitude},${longitude});
);
out center tags;
`.trim();
}

function curatedFallback(coords: Coordinates): Winery[] {
  const nearby = nearbyCurated(coords, 120000);
  return nearby.length > 0 ? nearby : withDistances(CURATED_WINERIES, coords);
}

async function queryOverpass(
  coords: Coordinates,
  radiusMeters: number,
): Promise<Winery[]> {
  const query = buildQuery(coords, radiusMeters);
  let lastError: unknown;

  for (const endpoint of OVERPASS_ENDPOINTS) {
    try {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 18000);
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `data=${encodeURIComponent(query)}`,
        signal: controller.signal,
      });
      clearTimeout(timeout);

      if (!response.ok) {
        lastError = new Error(`Overpass ${response.status}`);
        continue;
      }

      const json = (await response.json()) as { elements?: OsmElement[] };
      const mapped = (json.elements ?? [])
        .map(mapElement)
        .filter((w): w is Winery => Boolean(w));

      const seen = new Set<string>();
      const unique: Winery[] = [];
      for (const winery of mapped) {
        const key = `${winery.name.toLowerCase()}|${winery.latitude.toFixed(3)}|${winery.longitude.toFixed(3)}`;
        if (seen.has(key)) continue;
        seen.add(key);
        unique.push(winery);
      }

      return withDistances(unique, coords);
    } catch (error) {
      lastError = error;
    }
  }

  throw lastError ?? new Error('Overpass unavailable');
}

export type NearbyResult = {
  wineries: Winery[];
  fromFallback: boolean;
  message?: string;
};

export async function fetchNearbyWineries(
  coords: Coordinates,
  radiusMeters = 25000,
): Promise<NearbyResult> {
  try {
    const osm = await queryOverpass(coords, radiusMeters);
    if (osm.length > 0) {
      return { wineries: osm.slice(0, 60), fromFallback: false };
    }

    const wider = await queryOverpass(coords, radiusMeters * 2);
    if (wider.length > 0) {
      return {
        wineries: wider.slice(0, 60),
        fromFallback: false,
        message: 'Expanded search radius to find more wineries.',
      };
    }

    return {
      wineries: curatedFallback(coords),
      fromFallback: true,
      message:
        'No OpenStreetMap wineries nearby — showing curated wine country picks.',
    };
  } catch {
    return {
      wineries: curatedFallback(coords),
      fromFallback: true,
      message: 'Live map data unavailable — showing curated wine country picks.',
    };
  }
}

export function categoryLabel(category: Winery['category']): string {
  switch (category) {
    case 'vineyard':
      return 'Vineyard';
    case 'wine_shop':
      return 'Wine shop';
    case 'wine_cellar':
      return 'Wine cellar';
    case 'tasting_room':
      return 'Tasting room';
    default:
      return 'Winery';
  }
}
