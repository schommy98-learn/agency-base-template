import React from 'react';
import { View, StyleSheet, Switch, StyleProp, ViewStyle } from 'react-native';
import { Typography } from './Typography';
import { theme } from '@/constants/theme';

export interface ToggleRowProps {
  title: string;
  subtitle?: string;
  value: boolean;
  onValueChange: (val: boolean) => void;
  hideBorder?: boolean;
  style?: StyleProp<ViewStyle>;
}

export function ToggleRow({ title, subtitle, value, onValueChange, hideBorder = false, style }: ToggleRowProps) {
  return (
    <View style={[styles.container, !hideBorder && styles.border, style]}>
      <View style={styles.textBlock}>
        <Typography variant="h3" style={{ marginBottom: subtitle ? 4 : 0 }}>{title}</Typography>
        {subtitle && <Typography variant="muted">{subtitle}</Typography>}
      </View>
      <Switch
        value={value}
        onValueChange={onValueChange}
        trackColor={{ false: theme.colors.background.raised, true: theme.colors.brand.primary }}
        thumbColor={'#ffffff'}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 15,
  },
  border: {
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
  },
  textBlock: {
    flex: 1,
    paddingRight: 20,
  }
});