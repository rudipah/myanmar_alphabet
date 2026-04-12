import 'package:flutter/material.dart';

// Stroke paths based on official Myanmar handwriting chart
// Coordinates normalized 0.0–1.0 (x: left→right, y: top→bottom)
// All circles follow the direction shown in the official chart

class StrokeGuide {
  final List<Offset> points;
  final String label;
  const StrokeGuide({required this.points, required this.label});
}

const Map<String, List<StrokeGuide>> letterStrokes = {

  // က (Ka) — ကကြီး
  // Chart: RIGHT loop first (stroke 1), then LEFT loop (stroke 2)
  // Both loops are clockwise. Right loop slightly bigger.
  // Loops share a join at the center-bottom.
  'က': [
    // Stroke 1: RIGHT loop — start at top, clockwise
    StrokeGuide(label: '1', points: [
      Offset(0.60, 0.22),  // top of right loop
      Offset(0.67, 0.28),  // right side down
      Offset(0.69, 0.38),  // right curve
      Offset(0.65, 0.50),  // bottom right
      Offset(0.55, 0.55),  // bottom center
      Offset(0.46, 0.50),  // bottom left of right loop
      Offset(0.43, 0.40),  // left side up
      Offset(0.46, 0.29),  // left top curve
      Offset(0.54, 0.22),  // top back to start
      Offset(0.60, 0.22),  // close
    ]),
    // Stroke 2: LEFT loop — start at top, clockwise
    StrokeGuide(label: '2', points: [
      Offset(0.44, 0.24),  // top of left loop
      Offset(0.50, 0.20),  // top curve
      Offset(0.55, 0.24),  // top right — meets right loop
      Offset(0.55, 0.34),  // right side going down
      Offset(0.50, 0.46),  // bottom right of left loop
      Offset(0.41, 0.48),  // bottom center
      Offset(0.33, 0.43),  // bottom left
      Offset(0.30, 0.33),  // left side
      Offset(0.33, 0.24),  // left top
      Offset(0.40, 0.21),  // top back
      Offset(0.44, 0.24),  // close
    ]),
  ],

  // ခ (Kha) — ခခေါင်း: anticlockwise open circle, top curl
  // Chart shows: open C-shape from top going left/anticlockwise, top flick
  'ခ': [
    StrokeGuide(label: '1', points: [
      Offset(0.65, 0.28), Offset(0.60, 0.20), Offset(0.50, 0.18),
      Offset(0.40, 0.22), Offset(0.33, 0.32), Offset(0.32, 0.44),
      Offset(0.37, 0.55), Offset(0.48, 0.62), Offset(0.60, 0.60),
      Offset(0.68, 0.52), Offset(0.68, 0.40), Offset(0.62, 0.32),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.65, 0.28), Offset(0.70, 0.20), Offset(0.68, 0.13),
    ]),
  ],

  // ဂ (Ga) — clockwise circle with bottom tail curling right
  'ဂ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.20), Offset(0.62, 0.22), Offset(0.68, 0.32),
      Offset(0.68, 0.44), Offset(0.62, 0.54), Offset(0.50, 0.58),
      Offset(0.38, 0.54), Offset(0.32, 0.44), Offset(0.34, 0.32),
      Offset(0.42, 0.22), Offset(0.52, 0.20),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.50, 0.58), Offset(0.54, 0.66), Offset(0.62, 0.70),
      Offset(0.68, 0.66),
    ]),
  ],

  // ဃ (Gha) — anticlockwise circle + right top curl
  'ဃ': [
    StrokeGuide(label: '1', points: [
      Offset(0.55, 0.22), Offset(0.45, 0.20), Offset(0.35, 0.26),
      Offset(0.30, 0.37), Offset(0.33, 0.50), Offset(0.43, 0.58),
      Offset(0.55, 0.58), Offset(0.65, 0.52), Offset(0.68, 0.40),
      Offset(0.65, 0.28), Offset(0.55, 0.22),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.65, 0.28), Offset(0.72, 0.20), Offset(0.70, 0.13),
    ]),
  ],

  // င (Nga) — နငယ်: small anticlockwise loop, right arc down
  // Chart shows: small left loop then sweeping right curve downward
  'င': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.35), Offset(0.46, 0.30), Offset(0.38, 0.33),
      Offset(0.35, 0.42), Offset(0.40, 0.52), Offset(0.50, 0.55),
      Offset(0.60, 0.50), Offset(0.63, 0.40), Offset(0.58, 0.30),
      Offset(0.52, 0.35),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.62, 0.42), Offset(0.65, 0.55), Offset(0.60, 0.65),
      Offset(0.50, 0.68), Offset(0.40, 0.64),
    ]),
  ],

  // စ (Sa) — စပတ်လုံး: anticlockwise spiral inward
  // Chart shows: starts top-right, sweeps anticlockwise, spirals inward
  'စ': [
    StrokeGuide(label: '1', points: [
      Offset(0.65, 0.30), Offset(0.68, 0.22), Offset(0.60, 0.16),
      Offset(0.48, 0.17), Offset(0.37, 0.25), Offset(0.32, 0.38),
      Offset(0.35, 0.52), Offset(0.45, 0.62), Offset(0.57, 0.63),
      Offset(0.66, 0.56), Offset(0.68, 0.45), Offset(0.63, 0.36),
      Offset(0.55, 0.33), Offset(0.47, 0.37), Offset(0.45, 0.46),
      Offset(0.50, 0.53),
    ]),
  ],

  // ဆ (Hsa) — ဆခေါင်း: two loops — left anticlockwise, right clockwise
  'ဆ': [
    StrokeGuide(label: '1', points: [
      Offset(0.45, 0.25), Offset(0.37, 0.22), Offset(0.30, 0.30),
      Offset(0.30, 0.42), Offset(0.37, 0.52), Offset(0.47, 0.53),
      Offset(0.55, 0.46), Offset(0.55, 0.33), Offset(0.47, 0.25),
      Offset(0.45, 0.25),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.58, 0.28), Offset(0.65, 0.22), Offset(0.72, 0.28),
      Offset(0.73, 0.40), Offset(0.68, 0.52), Offset(0.58, 0.55),
      Offset(0.52, 0.48), Offset(0.54, 0.36), Offset(0.58, 0.28),
    ]),
  ],

  // ဇ (Za) — ဇကောက်: Z/S-curve shape
  'ဇ': [
    StrokeGuide(label: '1', points: [
      Offset(0.62, 0.22), Offset(0.50, 0.20), Offset(0.40, 0.26),
      Offset(0.36, 0.36), Offset(0.40, 0.46), Offset(0.52, 0.52),
      Offset(0.60, 0.58), Offset(0.62, 0.67), Offset(0.55, 0.73),
      Offset(0.44, 0.72),
    ]),
  ],

  // ဈ (Zha) — like ဇ with extra hook
  'ဈ': [
    StrokeGuide(label: '1', points: [
      Offset(0.55, 0.22), Offset(0.45, 0.20), Offset(0.36, 0.26),
      Offset(0.33, 0.37), Offset(0.37, 0.48), Offset(0.48, 0.54),
      Offset(0.58, 0.52), Offset(0.63, 0.43), Offset(0.60, 0.33),
      Offset(0.52, 0.28),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.55, 0.54), Offset(0.58, 0.64), Offset(0.54, 0.72),
      Offset(0.44, 0.72),
    ]),
  ],

  // ည (Nya) — ယကြီး: Y-shape with loops
  'ည': [
    StrokeGuide(label: '1', points: [
      Offset(0.38, 0.25), Offset(0.32, 0.32), Offset(0.33, 0.44),
      Offset(0.42, 0.52), Offset(0.52, 0.50), Offset(0.57, 0.40),
      Offset(0.53, 0.30), Offset(0.44, 0.27), Offset(0.38, 0.25),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.57, 0.28), Offset(0.64, 0.22), Offset(0.70, 0.28),
      Offset(0.70, 0.40), Offset(0.65, 0.52), Offset(0.55, 0.55),
    ]),
    StrokeGuide(label: '3', points: [
      Offset(0.52, 0.55), Offset(0.52, 0.65), Offset(0.46, 0.70),
    ]),
  ],

  // ဋ (Tta) — တဝိုက်: clockwise circle
  'ဋ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.20), Offset(0.62, 0.23), Offset(0.68, 0.34),
      Offset(0.66, 0.47), Offset(0.57, 0.55), Offset(0.45, 0.55),
      Offset(0.36, 0.47), Offset(0.34, 0.34), Offset(0.40, 0.23),
      Offset(0.52, 0.20),
    ]),
  ],

  // ဌ (Ttha) — clockwise circle + extra curl top right
  'ဌ': [
    StrokeGuide(label: '1', points: [
      Offset(0.50, 0.22), Offset(0.60, 0.24), Offset(0.66, 0.34),
      Offset(0.64, 0.46), Offset(0.55, 0.54), Offset(0.43, 0.53),
      Offset(0.35, 0.44), Offset(0.34, 0.32), Offset(0.42, 0.23),
      Offset(0.50, 0.22),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.64, 0.27), Offset(0.70, 0.20), Offset(0.72, 0.13),
    ]),
  ],

  // ဍ (Dda) — anticlockwise circle
  'ဍ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.22), Offset(0.42, 0.20), Offset(0.33, 0.28),
      Offset(0.31, 0.40), Offset(0.36, 0.52), Offset(0.48, 0.58),
      Offset(0.60, 0.54), Offset(0.66, 0.43), Offset(0.63, 0.30),
      Offset(0.54, 0.22),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.60, 0.54), Offset(0.65, 0.63), Offset(0.62, 0.70),
      Offset(0.52, 0.72),
    ]),
  ],

  // ဎ (Ddha) — anticlockwise circle + top right curl
  'ဎ': [
    StrokeGuide(label: '1', points: [
      Offset(0.54, 0.22), Offset(0.44, 0.20), Offset(0.35, 0.28),
      Offset(0.32, 0.40), Offset(0.37, 0.52), Offset(0.49, 0.57),
      Offset(0.60, 0.53), Offset(0.65, 0.42), Offset(0.62, 0.30),
      Offset(0.54, 0.22),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.63, 0.28), Offset(0.70, 0.20), Offset(0.68, 0.13),
    ]),
  ],

  // ဏ (Nna) — anticlockwise circle + vertical downstroke
  'ဏ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.22), Offset(0.42, 0.20), Offset(0.33, 0.28),
      Offset(0.31, 0.40), Offset(0.36, 0.52), Offset(0.48, 0.57),
      Offset(0.60, 0.52), Offset(0.65, 0.40), Offset(0.62, 0.28),
      Offset(0.52, 0.22),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.63, 0.40), Offset(0.63, 0.55), Offset(0.63, 0.70),
      Offset(0.58, 0.76),
    ]),
  ],

  // တ (Ta) — တဝိုက်: two clockwise circles
  'တ': [
    StrokeGuide(label: '1', points: [
      Offset(0.44, 0.24), Offset(0.50, 0.20), Offset(0.56, 0.24),
      Offset(0.58, 0.34), Offset(0.54, 0.45), Offset(0.46, 0.48),
      Offset(0.37, 0.44), Offset(0.34, 0.33), Offset(0.38, 0.25),
      Offset(0.44, 0.24),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.60, 0.26), Offset(0.67, 0.22), Offset(0.73, 0.28),
      Offset(0.74, 0.39), Offset(0.70, 0.50), Offset(0.60, 0.53),
      Offset(0.52, 0.49), Offset(0.50, 0.38),
    ]),
  ],

  // ထ (Hta) — two clockwise circles + top flick
  'ထ': [
    StrokeGuide(label: '1', points: [
      Offset(0.42, 0.26), Offset(0.48, 0.21), Offset(0.54, 0.25),
      Offset(0.56, 0.35), Offset(0.52, 0.46), Offset(0.43, 0.49),
      Offset(0.35, 0.44), Offset(0.33, 0.33), Offset(0.37, 0.25),
      Offset(0.42, 0.26),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.58, 0.28), Offset(0.65, 0.22), Offset(0.72, 0.28),
      Offset(0.73, 0.39), Offset(0.69, 0.49), Offset(0.59, 0.52),
      Offset(0.52, 0.47),
    ]),
    StrokeGuide(label: '3', points: [
      Offset(0.65, 0.22), Offset(0.68, 0.15), Offset(0.65, 0.10),
    ]),
  ],

  // ဒ (Da) — 3ဒေါင့်: Z/3-like shape
  'ဒ': [
    StrokeGuide(label: '1', points: [
      Offset(0.65, 0.22), Offset(0.52, 0.20), Offset(0.40, 0.27),
      Offset(0.36, 0.38), Offset(0.42, 0.48), Offset(0.54, 0.52),
      Offset(0.64, 0.48), Offset(0.68, 0.58), Offset(0.60, 0.68),
      Offset(0.48, 0.70), Offset(0.38, 0.65),
    ]),
  ],

  // ဓ (Dha) — large anticlockwise loop
  'ဓ': [
    StrokeGuide(label: '1', points: [
      Offset(0.62, 0.28), Offset(0.68, 0.20), Offset(0.62, 0.14),
      Offset(0.50, 0.16), Offset(0.38, 0.24), Offset(0.32, 0.36),
      Offset(0.34, 0.50), Offset(0.44, 0.60), Offset(0.56, 0.62),
      Offset(0.66, 0.56), Offset(0.70, 0.44), Offset(0.66, 0.33),
      Offset(0.55, 0.28), Offset(0.45, 0.32),
    ]),
  ],

  // န (Na) — နငယ်: anticlockwise circle + tail hook
  'န': [
    StrokeGuide(label: '1', points: [
      Offset(0.55, 0.22), Offset(0.45, 0.20), Offset(0.35, 0.28),
      Offset(0.32, 0.40), Offset(0.37, 0.52), Offset(0.49, 0.57),
      Offset(0.61, 0.52), Offset(0.65, 0.40), Offset(0.60, 0.28),
      Offset(0.52, 0.22),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.50, 0.57), Offset(0.50, 0.67), Offset(0.44, 0.73),
      Offset(0.36, 0.70),
    ]),
  ],

  // ပ (Pa) — ပစောက်: anticlockwise circle (exception to clockwise rule)
  'ပ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.22), Offset(0.42, 0.20), Offset(0.33, 0.28),
      Offset(0.31, 0.40), Offset(0.36, 0.52), Offset(0.48, 0.58),
      Offset(0.60, 0.53), Offset(0.65, 0.42), Offset(0.62, 0.30),
      Offset(0.52, 0.22),
    ]),
  ],

  // ဖ (Pha) — anticlockwise circle + cross stroke
  'ဖ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.22), Offset(0.42, 0.20), Offset(0.33, 0.28),
      Offset(0.31, 0.40), Offset(0.36, 0.52), Offset(0.48, 0.58),
      Offset(0.60, 0.53), Offset(0.65, 0.42), Offset(0.62, 0.30),
      Offset(0.52, 0.22),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.38, 0.38), Offset(0.50, 0.38), Offset(0.62, 0.38),
    ]),
  ],

  // ဗ (Ba) — anticlockwise circle + bottom right hook
  'ဗ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.22), Offset(0.42, 0.20), Offset(0.33, 0.28),
      Offset(0.31, 0.40), Offset(0.36, 0.52), Offset(0.48, 0.58),
      Offset(0.60, 0.53), Offset(0.65, 0.42), Offset(0.62, 0.30),
      Offset(0.52, 0.22),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.60, 0.53), Offset(0.65, 0.62), Offset(0.62, 0.70),
      Offset(0.52, 0.72),
    ]),
  ],

  // ဘ (Bha) — ဘကုန်း: anticlockwise circle + top right flick
  'ဘ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.24), Offset(0.42, 0.22), Offset(0.33, 0.30),
      Offset(0.31, 0.42), Offset(0.36, 0.54), Offset(0.48, 0.60),
      Offset(0.60, 0.55), Offset(0.65, 0.44), Offset(0.62, 0.32),
      Offset(0.52, 0.24),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.62, 0.30), Offset(0.70, 0.22), Offset(0.68, 0.15),
    ]),
  ],

  // မ (Ma) — မကြီး: two clockwise circles + tail
  'မ': [
    StrokeGuide(label: '1', points: [
      Offset(0.44, 0.24), Offset(0.50, 0.20), Offset(0.56, 0.24),
      Offset(0.57, 0.34), Offset(0.53, 0.45), Offset(0.44, 0.48),
      Offset(0.36, 0.44), Offset(0.33, 0.33), Offset(0.38, 0.25),
      Offset(0.44, 0.24),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.60, 0.26), Offset(0.67, 0.22), Offset(0.73, 0.28),
      Offset(0.74, 0.39), Offset(0.70, 0.50), Offset(0.60, 0.53),
      Offset(0.52, 0.49),
    ]),
    StrokeGuide(label: '3', points: [
      Offset(0.54, 0.53), Offset(0.54, 0.64), Offset(0.48, 0.70),
      Offset(0.40, 0.68),
    ]),
  ],

  // ယ (Ya) — ယပင်လက်: anticlockwise loop + right sweep down
  'ယ': [
    StrokeGuide(label: '1', points: [
      Offset(0.48, 0.25), Offset(0.40, 0.22), Offset(0.33, 0.30),
      Offset(0.33, 0.42), Offset(0.40, 0.50), Offset(0.50, 0.50),
      Offset(0.58, 0.43), Offset(0.57, 0.32), Offset(0.50, 0.26),
      Offset(0.48, 0.25),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.57, 0.38), Offset(0.63, 0.45), Offset(0.65, 0.56),
      Offset(0.60, 0.66), Offset(0.50, 0.70), Offset(0.40, 0.66),
    ]),
  ],

  // ရ (Ra) — ရကောက်: clockwise loop + tail curling right-down
  'ရ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.20), Offset(0.62, 0.23), Offset(0.67, 0.33),
      Offset(0.65, 0.44), Offset(0.57, 0.51), Offset(0.46, 0.50),
      Offset(0.38, 0.42), Offset(0.37, 0.31), Offset(0.44, 0.22),
      Offset(0.52, 0.20),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.55, 0.51), Offset(0.58, 0.62), Offset(0.65, 0.70),
      Offset(0.65, 0.78), Offset(0.57, 0.82), Offset(0.48, 0.78),
    ]),
  ],

  // လ (La) — anticlockwise circle (exception)
  'လ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.22), Offset(0.42, 0.20), Offset(0.33, 0.28),
      Offset(0.31, 0.40), Offset(0.36, 0.52), Offset(0.48, 0.58),
      Offset(0.60, 0.53), Offset(0.65, 0.42), Offset(0.62, 0.30),
      Offset(0.52, 0.22),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.48, 0.58), Offset(0.44, 0.68), Offset(0.38, 0.72),
    ]),
  ],

  // ဝ (Wa) — simple clockwise circle
  'ဝ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.20), Offset(0.62, 0.24), Offset(0.68, 0.35),
      Offset(0.67, 0.48), Offset(0.59, 0.57), Offset(0.48, 0.58),
      Offset(0.37, 0.52), Offset(0.32, 0.40), Offset(0.35, 0.28),
      Offset(0.44, 0.21), Offset(0.52, 0.20),
    ]),
  ],

  // သ (Tha) — open anticlockwise circle + tail
  'သ': [
    StrokeGuide(label: '1', points: [
      Offset(0.65, 0.35), Offset(0.68, 0.24), Offset(0.60, 0.17),
      Offset(0.48, 0.18), Offset(0.37, 0.26), Offset(0.32, 0.38),
      Offset(0.35, 0.52), Offset(0.46, 0.60), Offset(0.58, 0.59),
      Offset(0.66, 0.51), Offset(0.67, 0.40),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.52, 0.60), Offset(0.52, 0.70), Offset(0.46, 0.75),
    ]),
  ],

  // ဟ (Ha) — ဟကြီး: arch + right loop (exception)
  'ဟ': [
    StrokeGuide(label: '1', points: [
      Offset(0.36, 0.58), Offset(0.36, 0.36), Offset(0.42, 0.26),
      Offset(0.52, 0.23), Offset(0.62, 0.26), Offset(0.66, 0.36),
      Offset(0.66, 0.50),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.66, 0.40), Offset(0.72, 0.48), Offset(0.72, 0.60),
      Offset(0.64, 0.67), Offset(0.54, 0.65), Offset(0.50, 0.58),
    ]),
  ],

  // ဠ (Lla) — anticlockwise loop + down stroke (exception)
  'ဠ': [
    StrokeGuide(label: '1', points: [
      Offset(0.52, 0.22), Offset(0.42, 0.20), Offset(0.33, 0.28),
      Offset(0.31, 0.40), Offset(0.36, 0.52), Offset(0.48, 0.57),
      Offset(0.60, 0.52), Offset(0.65, 0.40), Offset(0.62, 0.28),
      Offset(0.52, 0.22),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.52, 0.57), Offset(0.52, 0.70), Offset(0.52, 0.80),
    ]),
  ],

  // အ (A) — ငယ်ကောက်: anticlockwise circle + top mark
  'အ': [
    StrokeGuide(label: '1', points: [
      Offset(0.55, 0.28), Offset(0.45, 0.24), Offset(0.35, 0.32),
      Offset(0.32, 0.44), Offset(0.37, 0.56), Offset(0.50, 0.62),
      Offset(0.62, 0.56), Offset(0.66, 0.44), Offset(0.62, 0.32),
      Offset(0.55, 0.28),
    ]),
    StrokeGuide(label: '2', points: [
      Offset(0.50, 0.20), Offset(0.50, 0.28),
    ]),
  ],
};
