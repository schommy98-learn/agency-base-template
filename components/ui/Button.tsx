import React from 'react';
import { TouchableOpacity, StyleSheet, ActivityIndicator, ViewStyle, StyleProp } from 'react-native';
import { Typography } from './Typography';
import { theme } from '@/constants/theme';

export interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'danger' | 'outline' | 'ghost';
  disabled?: boolean;
  loading?: boolean;
  style?: StyleProp<ViewStyle>;
  fullWidth?: boolean;
  testID?: string;
}

export function Button({
  title,
  onPress,
  variant = 'primary',
  disabled = false,
  loading = false,
  style,
  fullWidth = false,
  testID,
}: ButtonProps) {
  
  // Dynamic styling based on the variant
  const getBackgroundStyle = () => {
    if (disabled) return { backgroundColor: theme.colors.background.raised, opacity: 0.5 };
    switch (variant) {
      case 'primary': return { backgroundColor: theme.colors.brand.primary };
      case 'danger': return { backgroundColor: 'transparent', borderColor: theme.colors.brand.danger, borderWidth: 1 };
      case 'outline': return { backgroundColor: 'transparent', borderColor: theme.colors.border, borderWidth: 1 };
      case 'ghost': return { backgroundColor: 'transparent' };
      default: return { backgroundColor: theme.colors.brand.primary };
    }
  };

  const getTextColor = () => {
    if (disabled) return theme.colors.text.muted;
    switch (variant) {
      case 'primary': return theme.colors.text.inverse;
      case 'danger': return theme.colors.brand.danger;
      case 'outline': return theme.colors.text.main;
      case 'ghost': return theme.colors.brand.secondary;
      default: return theme.colors.text.inverse;
    }
  };

  return (
    <TouchableOpacity
      testID={testID} // <--- 2. ADD THIS HERE
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.8}
      style={[
        styles.base,
        getBackgroundStyle(),
        fullWidth && { width: '100%' },
        style
      ]}
    >
      {loading ? (
        <ActivityIndicator color={getTextColor()} />
      ) : (
        <Typography style={{ color: getTextColor(), fontWeight: 'bold', fontSize: 16 }}>
          {title}
        </Typography>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  base: {
    paddingVertical: 14,
    paddingHorizontal: 24,
    borderRadius: theme.radii.md,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
  },
});