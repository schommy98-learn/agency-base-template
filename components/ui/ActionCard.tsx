import React from 'react';
import { TouchableOpacity, View, StyleSheet, StyleProp, ViewStyle } from 'react-native';
import { Box } from './Box';
import { Typography } from './Typography';
import { theme } from '@/constants/theme';

export interface ActionCardProps {
  title: string;
  subtitle?: string;
  icon?: string | React.ReactNode;
  onPress: () => void;
  rightElement?: React.ReactNode;
  style?: StyleProp<ViewStyle>;
}

export function ActionCard({ title, subtitle, icon, onPress, rightElement, style }: ActionCardProps) {
  return (
    <TouchableOpacity onPress={onPress} activeOpacity={0.7} style={[styles.wrapper, style]}>
      <Box variant="surface" radius="xl" borderColor={theme.colors.border} padded style={styles.card}>
        
        {/* Optional Icon Array */}
        {icon && (
          <View style={styles.iconContainer}>
            {typeof icon === 'string' ? <Typography style={{ fontSize: 32 }}>{icon}</Typography> : icon}
          </View>
        )}

        {/* Text Block */}
        <View style={styles.textBlock}>
          <Typography variant="h2" style={{ marginBottom: 4 }}>{title}</Typography>
          {subtitle && <Typography variant="muted">{subtitle}</Typography>}
        </View>

        {/* Optional Right Action (like an arrow, active badge, or delete button) */}
        {rightElement && (
          <View style={styles.rightAction}>
            {rightElement}
          </View>
        )}

      </Box>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    marginBottom: 15,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  iconContainer: {
    marginRight: 15,
    justifyContent: 'center',
    alignItems: 'center',
  },
  textBlock: {
    flex: 1,
  },
  rightAction: {
    marginLeft: 10,
  }
});