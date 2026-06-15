import { SafeAreaView, StyleSheet, View } from 'react-native';

import { Box } from '@/components/ui/Box';
import { Typography } from '@/components/ui/Typography';
import { theme } from '@/constants/theme';

export default function HomeScreen() {
  return (
    <SafeAreaView style={styles.safeArea}>
      <Box variant="base" style={styles.screen}>
        <View style={styles.content}>
          <Typography variant="h1" align="center">
            Project Ready
          </Typography>
          <Typography variant="muted" align="center" style={styles.subtitle}>
            Replace this neutral starter screen with the first approved vertical slice.
          </Typography>
        </View>
      </Box>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: theme.colors.background.base,
  },
  screen: {
    flex: 1,
    padding: theme.spacing.lg,
  },
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: theme.spacing.md,
  },
  subtitle: {
    maxWidth: 420,
  },
});
