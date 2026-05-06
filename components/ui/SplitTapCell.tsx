import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet } from 'react-native';
import { theme } from '@/constants/theme';

const MILE_STEPS = [0.1, 0.25, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.1, 4.0, 5.0, 6.0, 6.2, 8.0, 10.0, 13.1, 15.0, 20.0, 26.2];
const METER_STEPS = [100, 200, 400, 800, 1000, 1200, 1500, 1600, 3200, 5000, 10000];

export const SplitTapCell = ({ value, onValueChange, step, type, isLogged, isFocused, onFocus, children, index, unit, onUnitToggle }: any) => {
  const [isEditing, setIsEditing] = useState(false);
  const [editRaw, setEditRaw] = useState('');

  // --- THE MICROWAVE FORMATTER ---
  const formatMicrowave = (raw: string) => {
    const padded = raw.padStart(4, '0');
    if (padded.length <= 4) {
        return `${padded.slice(0, 2)}:${padded.slice(2, 4)}`;
    } else if (padded.length === 5) {
        return `${padded.slice(0, 1)}:${padded.slice(1, 3)}:${padded.slice(3, 5)}`;
    } else {
        return `${padded.slice(0, 2)}:${padded.slice(2, 4)}:${padded.slice(4, 6)}`;
    }
  };

  const handleDurationChange = (text: string) => {
    const digits = text.replace(/\D/g, '').replace(/^0+/, '');
    if (digits.length <= 6) {
        setEditRaw(digits);
    }
  };

  const handleBlur = () => {
    setIsEditing(false);
    if (type === 'duration') {
        onValueChange(formatMicrowave(editRaw));
    } else {
        onValueChange(editRaw);
    }
  };

  const handleTap = (direction: 1 | -1) => {
    if (!isFocused) {
      onFocus();
      return; 
    }
    
    onFocus(); 
    
    if (type === 'duration') {
      const parts = (value || '00:00').toString().split(':');
      let totalSeconds = 0;
      if (parts.length === 2) totalSeconds = parseInt(parts[0] || '0') * 60 + parseInt(parts[1] || '0');
      else if (parts.length === 3) totalSeconds = parseInt(parts[0] || '0') * 3600 + parseInt(parts[1] || '0') * 60 + parseInt(parts[2] || '0');
      else totalSeconds = parseInt(value) || 0;
      
      let nextSeconds = totalSeconds + (direction * step);
      if (nextSeconds < 0) nextSeconds = 0;
      const mins = Math.floor(nextSeconds / 60);
      const secs = nextSeconds % 60;
      onValueChange(`${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`);
      return;
    }

    if (type === 'distance') {
      const current = parseFloat(value) || 0;
      const stepsArray = unit === 'm' ? METER_STEPS : MILE_STEPS;
      
      let closestIdx = 0;
      let minDiff = Infinity;
      stepsArray.forEach((val, idx) => {
         const diff = Math.abs(val - current);
         if (diff < minDiff) { minDiff = diff; closestIdx = idx; }
      });
      
      let nextIdx = closestIdx + direction;
      if (nextIdx < 0) nextIdx = 0;
      if (nextIdx >= stepsArray.length) nextIdx = stepsArray.length - 1;

      onValueChange(stepsArray[nextIdx].toString());
      return;
    }

    let current = parseFloat(value) || 0;
    let nextVal = current + (direction * step);
    if (nextVal < 0) nextVal = 0;
    
    if (type === 'weight') {
      const valStr = (nextVal % 1 === 0 ? nextVal.toString() : nextVal.toFixed(1));
      onValueChange(valStr);
      return;
    }
    onValueChange(Math.round(nextVal).toString());
  };

  const handleLongPress = () => {
    onFocus();
    if (type === 'duration') {
        setEditRaw((value || '').toString().replace(/:/g, '').replace(/^0+/, ''));
    } else {
        setEditRaw(value ? value.toString() : '');
    }
    setIsEditing(true);
  };

  const valString = value ? value.toString() : '';
  let textSize = 16;
  if (isFocused) {
      // Scale standard number inputs dynamically
      if (valString.length >= 7) textSize = 32;
      else if (valString.length >= 5) textSize = 42;
      else if (valString.length === 4) textSize = 52;
      else textSize = 64;
  }

  const cellHeight = isFocused ? 140 : 46;
  const cellRadius = isFocused ? 0 : 8;
  const borderWidth = isFocused ? 0 : 1;

  // --- DYNAMIC LABEL LOGIC (FIXED SPACING) ---
  let labelText = '';
  if (type === 'weight') labelText = 'LBS';
  if (type === 'reps') labelText = 'REPS';
  if (type === 'distance') labelText = unit === 'm' ? 'METERS' : 'MILES';
  if (type === 'duration') {
      if (isEditing) {
          // Tighter strings so they don't clip the checkbox
          labelText = editRaw.length > 4 ? 'HH:MM:SS' : 'MM:SS';
      } else {
          const parts = (value || '').toString().split(':');
          labelText = parts.length > 2 ? 'HH:MM:SS' : 'MM:SS';
      }
  }

  if (isEditing) {
    if (type === 'duration') {
        // Drop font size strictly for the HH:MM:SS editing view
        const microwaveSize = editRaw.length > 4 ? 36 : 48;
        
        return (
          <View style={[styles.cellContainer, { height: cellHeight, borderRadius: cellRadius, borderWidth, borderColor: theme.colors.brand.primary }]}>
            
            <Text style={[styles.cellFocusLabel, { letterSpacing: 2, paddingRight: 35 }]}>{labelText}</Text>
            
            {/* Added adjustsFontSizeToFit to prevent wrapping */}
            <Text 
                allowFontScaling={false} 
                adjustsFontSizeToFit={true} 
                numberOfLines={1} 
                style={[styles.cellInput, { fontSize: microwaveSize, marginTop: 25, paddingHorizontal: 35 }]}
            >
                {formatMicrowave(editRaw)}
            </Text>
            
            <TextInput
              style={[StyleSheet.absoluteFillObject, { opacity: 0 }]} 
              caretHidden={true}
              keyboardType="number-pad"
              value={formatMicrowave(editRaw)}
              onChangeText={handleDurationChange}
              autoFocus={true}
              onBlur={handleBlur}
              inputAccessoryViewID="done-toolbar"
              selectTextOnFocus={true} // <--- ADD THIS RIGHT HERE
            />
            {children}
          </View>
        );
    } else {
        return (
          <View style={[styles.cellContainer, { height: cellHeight, borderRadius: cellRadius, borderWidth, borderColor: theme.colors.brand.primary }]}>
            <Text style={styles.cellFocusLabel}>{labelText}</Text>
            <TextInput
              testID={`activeplan-${type}input-set${index}`}
              allowFontScaling={false}
              style={[styles.cellInput, { fontSize: textSize, marginTop: 15 }]}
              value={editRaw}
              onChangeText={setEditRaw}
              keyboardType={type === 'weight' || type === 'distance' ? "decimal-pad" : "number-pad"}
              autoFocus={true}
              onBlur={handleBlur}
              inputAccessoryViewID="done-toolbar"
              selectTextOnFocus={true}
            />
            {children}
          </View>
        );
    }
  }

  return (
    <View testID={`activeplan-${type}cell-set${index}`} style={[styles.cellContainer, isLogged ? styles.cellLogged : undefined, { height: cellHeight, borderRadius: cellRadius, borderWidth, backgroundColor: isFocused ? 'transparent' : '#121212' }]}>
        
        {isFocused ? <Text style={[styles.cellFocusLabel, type === 'duration' && { letterSpacing: 2, paddingRight: 35 }]}>{labelText}</Text> : null}
        
        {isFocused && type === 'distance' && (
          <TouchableOpacity 
            style={styles.unitToggleBtn} 
            onPress={() => onUnitToggle && onUnitToggle(unit === 'm' ? 'mi' : 'm')}
          >
            <Text style={styles.unitToggleText}>{unit === 'm' ? '⇄ MILES' : '⇄ METERS'}</Text>
          </TouchableOpacity>
        )}

        <Text allowFontScaling={false} adjustsFontSizeToFit={true} numberOfLines={1} style={[styles.cellValue, isLogged ? { color: theme.colors.brand.primary } : undefined, { fontSize: textSize, paddingHorizontal: type === 'duration' ? 35 : 10 }]}>
          {value}
        </Text>
        {isLogged ? null : (
          <>
            <TouchableOpacity testID={`activeplan-${type}decrement-set${index}`} style={styles.tapTargetLeft} onPress={() => handleTap(-1)} onLongPress={handleLongPress} activeOpacity={0.6} />
            <TouchableOpacity testID={`activeplan-${type}increment-set${index}`} style={styles.tapTargetRight} onPress={() => handleTap(1)} onLongPress={handleLongPress} activeOpacity={0.6} />
            {isFocused ? <Text style={styles.cornerMinus} pointerEvents="none">-</Text> : null}
            {isFocused ? <Text style={styles.cornerPlus} pointerEvents="none">+</Text> : null}
          </>
        )}
        {children}
    </View>
  );
};

const styles = StyleSheet.create({
  cellContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', position: 'relative', overflow: 'hidden' },
  cellLogged: { backgroundColor: 'transparent', borderColor: 'transparent' },
  cellValue: { fontWeight: 'bold', color: '#fff', textAlign: 'center' },
  cellInput: { color: theme.colors.brand.primary, textAlign: 'center', fontWeight: 'bold', padding: 0 },
  cellFocusLabel: { position: 'absolute', top: 15, fontSize: 10, fontWeight: 'bold', color: '#555', letterSpacing: 2, zIndex: 5, width: '100%', textAlign: 'center' },
  unitToggleBtn: { position: 'absolute', top: 10, right: 10, backgroundColor: '#333', paddingHorizontal: 8, paddingVertical: 4, borderRadius: 12, zIndex: 10 },
  unitToggleText: { color: theme.colors.brand.primary, fontSize: 9, fontWeight: 'bold', letterSpacing: 0.5 },
  tapTargetLeft: { position: 'absolute', left: 0, top: 0, bottom: 0, width: '50%', zIndex: 1 },
  tapTargetRight: { position: 'absolute', right: 0, top: 0, bottom: 0, width: '50%', zIndex: 1 },
  cornerMinus: { position: 'absolute', bottom: 10, left: 20, fontSize: 32, color: '#555', fontWeight: 'normal' },
  cornerPlus: { position: 'absolute', bottom: 10, right: 20, fontSize: 32, color: '#555', fontWeight: 'normal' },
});