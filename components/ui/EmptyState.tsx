import React from 'react';
import { TouchableOpacity, View, StyleSheet, StyleProp, ViewStyle } from 'react-native';
import { Typography } from './Typography';
import { theme } from '@/constants/theme';

export interface EmptyStateProps {
  icon?: string;
  title: string;
  message?: string;
  onPress?: () => void;
  style?: StyleProp<ViewStyle>;
}

export function EmptyState({ icon, title, message, onPress, style }: EmptyStateProps) {
  const content = (
    <>
      {icon && <Typography style={styles.icon}>{icon}</Typography>}
      <Typography variant="h3" align="center" style={styles.title}>{title}</Typography>
      {message && <Typography variant="muted" align="center">{message}</Typography>}
    </>
  );

  if (onPress) {
    return (
      <TouchableOpacity activeOpacity={0.7} onPress={onPress} style={[styles.container, style]}>
        {content}
      </TouchableOpacity>
    );
  }

  return (
    <View style={[styles.container, style]}>
      {content}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 30,
    borderWidth: 1,
    borderColor: '#444',
    borderStyle: 'dashed',
    borderRadius: theme.radii.lg,
    backgroundColor: 'rgba(255,255,255,0.02)', // Just a subtle highlight
  },
  icon: {
    fontSize: 40,
    marginBottom: 15,
  },
  title: {
    marginBottom: 8,
  }
});