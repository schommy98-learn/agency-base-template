import React from 'react';
import { Text, type TextProps } from 'react-native';
import { theme } from '@/constants/theme';

export interface TypographyProps extends TextProps {
  variant?: 'h1' | 'h2' | 'h3' | 'body' | 'muted' | 'inverse';
  align?: 'auto' | 'left' | 'right' | 'center';
}

export function Typography({
  style,
  variant = 'body',
  align = 'auto',
  ...rest
}: TypographyProps) {
  
  const getStyles = () => {
    switch (variant) {
      case 'h1': return { fontSize: 42, fontWeight: '900' as const, color: theme.colors.text.main, letterSpacing: -1 };
      case 'h2': return { fontSize: 24, fontWeight: 'bold' as const, color: theme.colors.text.main };
      case 'h3': return { fontSize: 16, fontWeight: 'bold' as const, color: theme.colors.text.main };
      case 'muted': return { fontSize: 12, fontWeight: '600' as const, color: theme.colors.text.muted };
      case 'inverse': return { fontSize: 16, fontWeight: 'bold' as const, color: theme.colors.text.inverse };
      default: return { fontSize: 16, color: theme.colors.text.main }; // body
    }
  };

  return (
    <Text
      style={[ getStyles(), { textAlign: align }, style ]}
      {...rest}
    />
  );
}