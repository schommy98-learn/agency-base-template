import { Platform } from 'react-native';

const palette = {
  black: '#0B0D10',
  charcoal: '#15191E',
  slate: '#222831',
  border: '#343B45',
  white: '#F7F8FA',
  muted: '#9AA4B2',
  primary: '#4F8CFF',
  secondary: '#76D0C4',
  danger: '#E05D5D',
};

export const theme = {
  colors: {
    background: {
      base: palette.black,
      surface: palette.charcoal,
      raised: palette.slate,
    },
    text: {
      main: palette.white,
      muted: palette.muted,
      inverse: palette.black,
    },
    brand: {
      primary: palette.primary,
      secondary: palette.secondary,
      danger: palette.danger,
    },
    border: palette.border,
  },
  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
  },
  radii: {
    sm: 6,
    md: 10,
    lg: 16,
    xl: 22,
  },
} as const;

export const Colors = {
  light: {
    text: '#11181C',
    background: '#FFFFFF',
    tint: palette.primary,
    icon: '#687076',
    tabIconDefault: '#687076',
    tabIconSelected: palette.primary,
  },
  dark: {
    text: palette.white,
    background: palette.black,
    tint: palette.primary,
    icon: palette.muted,
    tabIconDefault: palette.muted,
    tabIconSelected: palette.primary,
  },
};

export const Fonts = Platform.select({
  ios: {
    sans: 'system-ui',
    serif: 'ui-serif',
    rounded: 'ui-rounded',
    mono: 'ui-monospace',
  },
  default: {
    sans: 'normal',
    serif: 'serif',
    rounded: 'normal',
    mono: 'monospace',
  },
  web: {
    sans: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif",
    serif: "Georgia, 'Times New Roman', serif",
    rounded: "'SF Pro Rounded', 'Hiragino Maru Gothic ProN', Meiryo, 'MS PGothic', sans-serif",
    mono: "SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace",
  },
});
