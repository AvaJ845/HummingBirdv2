export type WineType = 'red' | 'white' | 'rose' | 'sparkling' | 'dessert';

export interface Coordinates {
  latitude: number;
  longitude: number;
}

export interface Winery {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  distanceMeters?: number;
  address?: string;
  phone?: string;
  website?: string;
  hours?: string;
  category: 'winery' | 'vineyard' | 'wine_shop' | 'wine_cellar' | 'tasting_room';
  rating?: number;
  reviewCount?: number;
  description?: string;
  source: 'osm' | 'curated';
}

export interface Wine {
  id: string;
  name: string;
  winery: string;
  region: string;
  country: string;
  type: WineType;
  vintage?: number;
  rating: number;
  ratingsCount: number;
  priceEstimate: number;
  grapes: string[];
  tastingNotes: string[];
  description: string;
  color: string;
  alcohol?: number;
}

export type EasyAction =
  | 'nearby'
  | 'discover'
  | 'reds'
  | 'whites'
  | 'weekend';
