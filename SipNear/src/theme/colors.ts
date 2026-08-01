export const colors = {
  burgundy: '#6B1D2A',
  burgundyDeep: '#4A1220',
  burgundySoft: '#8B3A46',
  wine: '#9B2335',
  rose: '#C46A7A',
  gold: '#C9A227',
  goldSoft: '#E8D48B',
  cream: '#FBF7F2',
  creamDark: '#F3EBE1',
  parchment: '#FFFDF9',
  ink: '#1C1412',
  inkSoft: '#4A3F3A',
  muted: '#8A7E76',
  border: '#E8DDD2',
  white: '#FFFFFF',
  success: '#2F6B4F',
  mapPin: '#6B1D2A',
  rating: '#C9A227',
  shadow: 'rgba(74, 18, 32, 0.12)',
  overlay: 'rgba(28, 20, 18, 0.45)',
};

export const gradients = {
  hero: [colors.burgundyDeep, colors.burgundy, colors.wine] as const,
  easyButton: [colors.burgundy, colors.wine] as const,
  card: [colors.parchment, colors.cream] as const,
  night: ['#2A1218', '#4A1220'] as const,
};
