import React from 'react';
import { View, type ViewProps } from 'react-native';
import { theme } from '@/constants/theme';

export interface BoxProps extends ViewProps {
  variant?: 'base' | 'surface' | 'raised';
  padded?: boolean;
  radius?: keyof typeof theme.radii | 'none';
  borderColor?: string;
}

export function Box({ 
  style, 
  variant = 'base', 
  padded = false, 
  radius = 'none',
  borderColor,
  ...otherProps 
}: BoxProps) {
  return (
    <View 
      style={[
        { backgroundColor: theme.colors.background[variant] },
        padded && { padding: theme.spacing.md },
        radius !== 'none' && { borderRadius: theme.radii[radius] },
        borderColor && { borderWidth: 1, borderColor },
        style
      ]} 
      {...otherProps} 
    />
  );
}