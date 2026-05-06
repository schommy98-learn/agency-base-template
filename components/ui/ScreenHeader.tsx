import React from 'react';
import { View, TouchableOpacity, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { Typography } from './Typography';
import { Box } from './Box';
import { theme } from '@/constants/theme';

export interface ScreenHeaderProps {
  title: string;
  subtitle?: string;
  backPath?: string | 'auto'; // 'auto' uses router.back(), string uses router.push()
  backLabel?: string;
  rightAction?: React.ReactNode; // e.g., a "Save" button or "+ Add" link
}

export function ScreenHeader({ title, subtitle, backPath, backLabel = 'Back', rightAction }: ScreenHeaderProps) {
  const router = useRouter();

  const handleBack = () => {
    if (backPath === 'auto') router.back();
    else if (backPath) router.push(backPath as any);
  };

  return (
    <Box variant="surface" style={styles.header}>
      {/* Top Nav Row */}
      {(backPath || rightAction) && (
        <View style={styles.topRow}>
          {backPath ? (
            <TouchableOpacity testID="header-back-btn" onPress={handleBack}>
              <Typography variant="h3" style={{ color: theme.colors.brand.primary }}>
                {"<"} {backLabel}
              </Typography>
            </TouchableOpacity>
          ) : <View />}

          {rightAction && (
            <View>
              {rightAction}
            </View>
          )}
        </View>
      )}

      {/* Titles */}
      <Typography variant="h1" style={styles.title}>{title}</Typography>
      {subtitle && <Typography variant="muted">{subtitle}</Typography>}
    </Box>
  );
}

const styles = StyleSheet.create({
  header: {
    padding: 20,
    paddingTop: 60,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
    marginBottom: 15, // Gives breathing room before the ScrollView starts
  },
  topRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  title: {
    fontSize: 32,
  }
});