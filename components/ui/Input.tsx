import React, { useState } from 'react';
import { View, TextInput, StyleSheet, TextInputProps, StyleProp, ViewStyle } from 'react-native';
import { Typography } from './Typography';
import { theme } from '@/constants/theme';

export interface InputProps extends TextInputProps {
  label?: string;
  containerStyle?: StyleProp<ViewStyle>;
}

export function Input({ label, containerStyle, onFocus, onBlur, ...rest }: InputProps) {
  const [isFocused, setIsFocused] = useState(false);

  return (
    <View style={[styles.container, containerStyle]}>
      {label && (
        <Typography variant="muted" style={styles.label}>
          {label}
        </Typography>
      )}
      <TextInput
        style={[
          styles.input,
          isFocused && styles.inputFocused
        ]}
        placeholderTextColor={theme.colors.text.muted}
        onFocus={(e) => {
          setIsFocused(true);
          onFocus && onFocus(e);
        }}
        onBlur={(e) => {
          setIsFocused(false);
          onBlur && onBlur(e);
        }}
        {...rest}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: 15,
  },
  label: {
    marginBottom: 8,
    textTransform: 'uppercase',
    letterSpacing: 1,
    fontSize: 12,
    color: theme.colors.brand.secondary,
  },
  input: {
    backgroundColor: '#121212',
    color: theme.colors.text.main,
    fontSize: 16,
    padding: 15,
    borderRadius: theme.radii.md,
    borderWidth: 1,
    borderColor: theme.colors.border,
  },
  inputFocused: {
    borderColor: theme.colors.brand.primary,
  },
});