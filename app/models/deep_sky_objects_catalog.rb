# frozen_string_literal: true

class DeepSkyObjectsCatalog
  SHOWPIECES = [
    "M6", "M7", "M8", "M11", "M13", "M17", "M22", "M27", "M31", "M35",
    "M37", "M42", "M44", "M45", "M51", "M57", "M81", "M82", "M101", "M104",
    "NGC 104", "NGC 253", "NGC 869", "NGC 3372", "NGC 3532", "NGC 4755",
    "NGC 5128", "NGC 5139", "NGC 6231", "NGC 6752"
  ].freeze

  NOTABLE = [
    "M1", "M2", "M3", "M4", "M5", "M10", "M12", "M15", "M16", "M20",
    "M23", "M24", "M25", "M33", "M34", "M36", "M38", "M39", "M41", "M46",
    "M47", "M48", "M50", "M52", "M53", "M55", "M63", "M64", "M65", "M66",
    "M71", "M78", "M92", "M93", "M97", "M103", "M105", "M106", "M110",
    "NGC 884", "NGC 2070", "NGC 2516", "NGC 3766", "NGC 4945", "NGC 6397"
  ].freeze

  FAINT = [
    "M40", "M43", "M68", "M72", "M73", "M74", "M76", "M77", "M89",
    "M91", "M95", "M96", "M98", "M99", "M100", "M102", "M108", "M109"
  ].freeze

  NAKED_EYE = [
    "M6", "M7", "M8", "M24", "M25", "M31", "M39", "M41", "M42", "M44",
    "M45", "M47", "M48",
    "NGC 104", "NGC 869", "NGC 884", "NGC 2516", "NGC 3372", "NGC 3532",
    "NGC 4755", "NGC 5139", "NGC 6231"
  ].freeze

  BINOCULARS = [
    "M2", "M3", "M4", "M5", "M10", "M11", "M12", "M13", "M15", "M16",
    "M17", "M18", "M20", "M21", "M22", "M23", "M26", "M27", "M29", "M33",
    "M34", "M35", "M36", "M37", "M38", "M46", "M50", "M52", "M55", "M62",
    "M67", "M71", "M79", "M80", "M92", "M93", "M103",
    "NGC 253", "NGC 3766", "NGC 5128", "NGC 6397", "NGC 6752", "NGC 7000"
  ].freeze

  LARGE_TELESCOPE = [
    "M58", "M59", "M60", "M61", "M68", "M72", "M74", "M76", "M77", "M84",
    "M85", "M86", "M87", "M88", "M89", "M90", "M91", "M95", "M96", "M98",
    "M99", "M100", "M102", "M108", "M109",
    "NGC 891"
  ].freeze

  MESSIER_OBJECTS = [
    {
      number: 1,
      ngc: 1952,
      name: "Crab Nebula",
      type: :supernova_remnant,
      constellation: :tau,
      magnitude: 8.4,
      size: {major_arcminutes: 6, minor_arcminutes: 4},
      distance_ly: 6500,
      ra: {h: 5, m: 34, s: 31.94},
      dec: {d: 22, m: 0, s: 52.2}
    },
    {
      number: 2,
      ngc: 7089,
      name: nil,
      type: :globular_cluster,
      constellation: :aqr,
      magnitude: 6.3,
      size: {major_arcminutes: 16},
      distance_ly: 37500,
      ra: {h: 21, m: 33, s: 27.02},
      dec: {sign: -1, d: 0, m: 49, s: 23.7}
    },
    {
      number: 3,
      ngc: 5272,
      name: nil,
      type: :globular_cluster,
      constellation: :cvn,
      magnitude: 6.2,
      size: {major_arcminutes: 18},
      distance_ly: 33900,
      ra: {h: 13, m: 42, s: 11.62},
      dec: {d: 28, m: 22, s: 38.2}
    },
    {
      number: 4,
      ngc: 6121,
      name: nil,
      type: :globular_cluster,
      constellation: :sco,
      magnitude: 5.9,
      size: {major_arcminutes: 36},
      distance_ly: 7200,
      ra: {h: 16, m: 23, s: 35.22},
      dec: {d: -26, m: 31, s: 32.7}
    },
    {
      number: 5,
      ngc: 5904,
      name: nil,
      type: :globular_cluster,
      constellation: :ser,
      magnitude: 5.7,
      size: {major_arcminutes: 23},
      distance_ly: 24500,
      ra: {h: 15, m: 18, s: 33.22},
      dec: {d: 2, m: 4, s: 51.7}
    },
    {
      number: 6,
      ngc: 6405,
      name: "Butterfly Cluster",
      type: :open_cluster,
      constellation: :sco,
      magnitude: 4.2,
      size: {major_arcminutes: 25},
      distance_ly: 1600,
      ra: {h: 17, m: 40, s: 20.0},
      dec: {d: -32, m: 15, s: 12.0}
    },
    {
      number: 7,
      ngc: 6475,
      name: "Ptolemy's Cluster",
      type: :open_cluster,
      constellation: :sco,
      magnitude: 3.3,
      size: {major_arcminutes: 80},
      distance_ly: 800,
      ra: {h: 17, m: 53, s: 51.0},
      dec: {d: -34, m: 47, s: 36.0}
    },
    {
      number: 8,
      ngc: 6523,
      name: "Lagoon Nebula",
      type: :nebula_with_cluster,
      constellation: :sgr,
      magnitude: 5.8,
      size: {major_arcminutes: 90, minor_arcminutes: 40},
      distance_ly: 5200,
      ra: {h: 18, m: 3, s: 37.0},
      dec: {d: -24, m: 23, s: 12.0}
    },
    {
      number: 9,
      ngc: 6333,
      name: nil,
      type: :globular_cluster,
      constellation: :oph,
      magnitude: 7.7,
      size: {major_arcminutes: 12},
      distance_ly: 25800,
      ra: {h: 17, m: 19, s: 11.78},
      dec: {d: -18, m: 30, s: 58.5}
    },
    {
      number: 10,
      ngc: 6254,
      name: nil,
      type: :globular_cluster,
      constellation: :oph,
      magnitude: 6.4,
      size: {major_arcminutes: 20},
      distance_ly: 14300,
      ra: {h: 16, m: 57, s: 8.92},
      dec: {d: -4, m: 5, s: 58.0}
    },
    {
      number: 11,
      ngc: 6705,
      name: "Wild Duck Cluster",
      type: :open_cluster,
      constellation: :sct,
      magnitude: 5.8,
      size: {major_arcminutes: 14},
      distance_ly: 6000,
      ra: {h: 18, m: 51, s: 5.0},
      dec: {d: -6, m: 16, s: 12.0}
    },
    {
      number: 12,
      ngc: 6218,
      name: nil,
      type: :globular_cluster,
      constellation: :oph,
      magnitude: 6.1,
      size: {major_arcminutes: 16},
      distance_ly: 16000,
      ra: {h: 16, m: 47, s: 14.18},
      dec: {d: -1, m: 56, s: 54.7}
    },
    {
      number: 13,
      ngc: 6205,
      name: "Hercules Cluster",
      type: :globular_cluster,
      constellation: :her,
      magnitude: 5.8,
      size: {major_arcminutes: 20},
      distance_ly: 25100,
      ra: {h: 16, m: 41, s: 41.24},
      dec: {d: 36, m: 27, s: 35.5}
    },
    {
      number: 14,
      ngc: 6402,
      name: nil,
      type: :globular_cluster,
      constellation: :oph,
      magnitude: 7.6,
      size: {major_arcminutes: 11.7},
      distance_ly: 30300,
      ra: {h: 17, m: 37, s: 36.10},
      dec: {d: -3, m: 14, s: 45.3}
    },
    {
      number: 15,
      ngc: 7078,
      name: nil,
      type: :globular_cluster,
      constellation: :peg,
      magnitude: 6.2,
      size: {major_arcminutes: 18},
      distance_ly: 33600,
      ra: {h: 21, m: 29, s: 58.33},
      dec: {d: 12, m: 10, s: 1.2}
    },
    {
      number: 16,
      ngc: 6611,
      name: "Eagle Nebula",
      type: :nebula_with_cluster,
      constellation: :ser,
      magnitude: 6.0,
      size: {major_arcminutes: 7},
      distance_ly: 7000,
      ra: {h: 18, m: 18, s: 48.0},
      dec: {d: -13, m: 48, s: 24.0}
    },
    {
      number: 17,
      ngc: 6618,
      name: "Omega Nebula",
      type: :nebula_with_cluster,
      constellation: :sgr,
      magnitude: 6.0,
      size: {major_arcminutes: 11},
      distance_ly: 5000,
      ra: {h: 18, m: 20, s: 47.0},
      dec: {d: -16, m: 10, s: 18.0}
    },
    {
      number: 18,
      ngc: 6613,
      name: nil,
      type: :open_cluster,
      constellation: :sgr,
      magnitude: 6.9,
      size: {major_arcminutes: 9},
      distance_ly: 4900,
      ra: {h: 18, m: 19, s: 58.0},
      dec: {d: -17, m: 6, s: 6.0}
    },
    {
      number: 19,
      ngc: 6273,
      name: nil,
      type: :globular_cluster,
      constellation: :oph,
      magnitude: 6.8,
      size: {major_arcminutes: 17},
      distance_ly: 28000,
      ra: {h: 17, m: 2, s: 37.69},
      dec: {d: -26, m: 16, s: 4.6}
    },
    {
      number: 20,
      ngc: 6514,
      name: "Trifid Nebula",
      type: :nebula_with_cluster,
      constellation: :sgr,
      magnitude: 6.3,
      size: {major_arcminutes: 28},
      distance_ly: 5200,
      ra: {h: 18, m: 2, s: 23.0},
      dec: {d: -23, m: 1, s: 48.0}
    },
    {
      number: 21,
      ngc: 6531,
      name: nil,
      type: :open_cluster,
      constellation: :sgr,
      magnitude: 5.9,
      size: {major_arcminutes: 13},
      distance_ly: 4250,
      ra: {h: 18, m: 4, s: 13.0},
      dec: {d: -22, m: 29, s: 24.0}
    },
    {
      number: 22,
      ngc: 6656,
      name: nil,
      type: :globular_cluster,
      constellation: :sgr,
      magnitude: 5.1,
      size: {major_arcminutes: 32},
      distance_ly: 10400,
      ra: {h: 18, m: 36, s: 23.94},
      dec: {d: -23, m: 54, s: 17.1}
    },
    {
      number: 23,
      ngc: 6494,
      name: nil,
      type: :open_cluster,
      constellation: :sgr,
      magnitude: 5.5,
      size: {major_arcminutes: 27},
      distance_ly: 2150,
      ra: {h: 17, m: 56, s: 54.0},
      dec: {d: -19, m: 1, s: 0.0}
    },
    {
      number: 24,
      ngc: 6603,
      name: "Sagittarius Star Cloud",
      type: :star_cloud,
      constellation: :sgr,
      magnitude: 4.6,
      size: {major_arcminutes: 90},
      distance_ly: 10000,
      ra: {h: 18, m: 16, s: 32.0},
      dec: {d: -18, m: 29, s: 12.0}
    },
    {
      number: 25,
      ngc: 4725,
      name: nil,
      type: :open_cluster,
      constellation: :sgr,
      magnitude: 4.6,
      size: {major_arcminutes: 40},
      distance_ly: 2000,
      ra: {h: 18, m: 31, s: 47.0},
      dec: {d: -19, m: 6, s: 48.0}
    },
    {
      number: 26,
      ngc: 6694,
      name: nil,
      type: :open_cluster,
      constellation: :sct,
      magnitude: 8.0,
      size: {major_arcminutes: 15},
      distance_ly: 5000,
      ra: {h: 18, m: 45, s: 18.0},
      dec: {d: -9, m: 23, s: 60.0}
    },
    {
      number: 27,
      ngc: 6853,
      name: "Dumbbell Nebula",
      type: :planetary_nebula,
      constellation: :vul,
      magnitude: 7.5,
      size: {major_arcminutes: 8, minor_arcminutes: 5.7},
      distance_ly: 1360,
      ra: {h: 19, m: 59, s: 36.34},
      dec: {d: 22, m: 43, s: 16.1}
    },
    {
      number: 28,
      ngc: 6626,
      name: nil,
      type: :globular_cluster,
      constellation: :sgr,
      magnitude: 6.8,
      size: {major_arcminutes: 11.2},
      distance_ly: 18300,
      ra: {h: 18, m: 24, s: 32.89},
      dec: {d: -24, m: 52, s: 11.4}
    },
    {
      number: 29,
      ngc: 6913,
      name: nil,
      type: :open_cluster,
      constellation: :cyg,
      magnitude: 6.6,
      size: {major_arcminutes: 7},
      distance_ly: 4000,
      ra: {h: 20, m: 23, s: 56.0},
      dec: {d: 38, m: 31, s: 24.0}
    },
    {
      number: 30,
      ngc: 7099,
      name: nil,
      type: :globular_cluster,
      constellation: :cap,
      magnitude: 7.5,
      size: {major_arcminutes: 12},
      distance_ly: 26100,
      ra: {h: 21, m: 40, s: 22.12},
      dec: {d: -23, m: 10, s: 47.5}
    },
    {
      number: 31,
      ngc: 224,
      name: "Andromeda Galaxy",
      type: :spiral_galaxy,
      constellation: :and,
      magnitude: 3.4,
      size: {major_arcminutes: 192, minor_arcminutes: 60},
      distance_ly: 2540000,
      ra: {h: 0, m: 42, s: 44.3},
      dec: {d: 41, m: 16, s: 9.0}
    },
    {
      number: 32,
      ngc: 221,
      name: nil,
      type: :elliptical_galaxy,
      constellation: :and,
      magnitude: 8.1,
      size: {major_arcminutes: 8, minor_arcminutes: 6},
      distance_ly: 2490000,
      ra: {h: 0, m: 42, s: 41.8},
      dec: {d: 40, m: 51, s: 55.0}
    },
    {
      number: 33,
      ngc: 598,
      name: "Triangulum Galaxy",
      type: :spiral_galaxy,
      constellation: :tri,
      magnitude: 5.7,
      size: {major_arcminutes: 70, minor_arcminutes: 42},
      distance_ly: 2730000,
      ra: {h: 1, m: 33, s: 50.9},
      dec: {d: 30, m: 39, s: 36.7}
    },
    {
      number: 34,
      ngc: 1039,
      name: nil,
      type: :open_cluster,
      constellation: :per,
      magnitude: 5.2,
      size: {major_arcminutes: 35},
      distance_ly: 1400,
      ra: {h: 2, m: 42, s: 5.0},
      dec: {d: 42, m: 45, s: 42.0}
    },
    {
      number: 35,
      ngc: 2168,
      name: nil,
      type: :open_cluster,
      constellation: :gem,
      magnitude: 5.1,
      size: {major_arcminutes: 28},
      distance_ly: 2800,
      ra: {h: 6, m: 9, s: 0.0},
      dec: {d: 24, m: 21, s: 0.0}
    },
    {
      number: 36,
      ngc: 1960,
      name: nil,
      type: :open_cluster,
      constellation: :aur,
      magnitude: 6.0,
      size: {major_arcminutes: 12},
      distance_ly: 4100,
      ra: {h: 5, m: 36, s: 18.0},
      dec: {d: 34, m: 8, s: 24.0}
    },
    {
      number: 37,
      ngc: 2099,
      name: nil,
      type: :open_cluster,
      constellation: :aur,
      magnitude: 5.6,
      size: {major_arcminutes: 24},
      distance_ly: 4400,
      ra: {h: 5, m: 52, s: 18.0},
      dec: {d: 32, m: 33, s: 12.0}
    },
    {
      number: 38,
      ngc: 1912,
      name: nil,
      type: :open_cluster,
      constellation: :aur,
      magnitude: 6.4,
      size: {major_arcminutes: 21},
      distance_ly: 4200,
      ra: {h: 5, m: 28, s: 42.0},
      dec: {d: 35, m: 51, s: 18.0}
    },
    {
      number: 39,
      ngc: 7092,
      name: nil,
      type: :open_cluster,
      constellation: :cyg,
      magnitude: 4.6,
      size: {major_arcminutes: 32},
      distance_ly: 825,
      ra: {h: 21, m: 32, s: 12.0},
      dec: {d: 48, m: 26, s: 0.0}
    },
    {
      number: 40,
      ngc: nil,
      name: "Winnecke 4",
      type: :double_star,
      constellation: :uma,
      magnitude: 9.6,
      size: {major_arcminutes: 0.8},
      distance_ly: 510,
      ra: {h: 12, m: 22, s: 12.5},
      dec: {d: 58, m: 4, s: 59.0}
    },
    {
      number: 41,
      ngc: 2287,
      name: nil,
      type: :open_cluster,
      constellation: :cma,
      magnitude: 4.5,
      size: {major_arcminutes: 38},
      distance_ly: 2300,
      ra: {h: 6, m: 46, s: 0.0},
      dec: {d: -20, m: 45, s: 24.0}
    },
    {
      number: 42,
      ngc: 1976,
      name: "Orion Nebula",
      type: :nebula,
      constellation: :ori,
      magnitude: 4.0,
      size: {major_arcminutes: 85, minor_arcminutes: 60},
      distance_ly: 1344,
      ra: {h: 5, m: 35, s: 17.3},
      dec: {d: -5, m: 23, s: 28.0}
    },
    {
      number: 43,
      ngc: 1982,
      name: "De Mairan's Nebula",
      type: :nebula,
      constellation: :ori,
      magnitude: 9.0,
      size: {major_arcminutes: 20, minor_arcminutes: 15},
      distance_ly: 1600,
      ra: {h: 5, m: 35, s: 31.0},
      dec: {d: -5, m: 16, s: 3.0}
    },
    {
      number: 44,
      ngc: 2632,
      name: "Beehive Cluster",
      type: :open_cluster,
      constellation: :cnc,
      magnitude: 3.1,
      size: {major_arcminutes: 95},
      distance_ly: 577,
      ra: {h: 8, m: 40, s: 24.0},
      dec: {d: 19, m: 40, s: 0.0}
    },
    {
      number: 45,
      ngc: nil,
      name: "Pleiades",
      type: :open_cluster,
      constellation: :tau,
      magnitude: 1.6,
      size: {major_arcminutes: 110},
      distance_ly: 444,
      ra: {h: 3, m: 47, s: 24.0},
      dec: {d: 24, m: 7, s: 0.0}
    },
    {
      number: 46,
      ngc: 2437,
      name: nil,
      type: :open_cluster,
      constellation: :pup,
      magnitude: 6.1,
      size: {major_arcminutes: 27},
      distance_ly: 5400,
      ra: {h: 7, m: 41, s: 46.0},
      dec: {d: -14, m: 48, s: 36.0}
    },
    {
      number: 47,
      ngc: 2422,
      name: nil,
      type: :open_cluster,
      constellation: :pup,
      magnitude: 4.4,
      size: {major_arcminutes: 30},
      distance_ly: 1600,
      ra: {h: 7, m: 36, s: 35.0},
      dec: {d: -14, m: 28, s: 58.0}
    },
    {
      number: 48,
      ngc: 2548,
      name: nil,
      type: :open_cluster,
      constellation: :hya,
      magnitude: 5.8,
      size: {major_arcminutes: 54},
      distance_ly: 1500,
      ra: {h: 8, m: 13, s: 43.0},
      dec: {d: -5, m: 45, s: 0.0}
    },
    {
      number: 49,
      ngc: 4472,
      name: nil,
      type: :elliptical_galaxy,
      constellation: :vir,
      magnitude: 8.4,
      size: {major_arcminutes: 10, minor_arcminutes: 8},
      distance_ly: 55900000,
      ra: {h: 12, m: 29, s: 46.7},
      dec: {d: 8, m: 0, s: 2.0}
    },
    {
      number: 50,
      ngc: 2323,
      name: nil,
      type: :open_cluster,
      constellation: :mon,
      magnitude: 5.9,
      size: {major_arcminutes: 16},
      distance_ly: 3200,
      ra: {h: 7, m: 2, s: 42.0},
      dec: {d: -8, m: 23, s: 24.0}
    },
    {
      number: 51,
      ngc: 5194,
      name: "Whirlpool Galaxy",
      type: :spiral_galaxy,
      constellation: :cvn,
      magnitude: 8.4,
      size: {major_arcminutes: 11, minor_arcminutes: 8},
      distance_ly: 23000000,
      ra: {h: 13, m: 29, s: 52.7},
      dec: {d: 47, m: 11, s: 43.0}
    },
    {
      number: 52,
      ngc: 7654,
      name: nil,
      type: :open_cluster,
      constellation: :cas,
      magnitude: 6.9,
      size: {major_arcminutes: 13},
      distance_ly: 5000,
      ra: {h: 23, m: 24, s: 48.0},
      dec: {d: 61, m: 35, s: 36.0}
    },
    {
      number: 53,
      ngc: 5024,
      name: nil,
      type: :globular_cluster,
      constellation: :com,
      magnitude: 7.7,
      size: {major_arcminutes: 13},
      distance_ly: 58000,
      ra: {h: 13, m: 12, s: 55.25},
      dec: {d: 18, m: 10, s: 9.0}
    },
    {
      number: 54,
      ngc: 6715,
      name: nil,
      type: :globular_cluster,
      constellation: :sgr,
      magnitude: 7.7,
      size: {major_arcminutes: 12},
      distance_ly: 87400,
      ra: {h: 18, m: 55, s: 3.33},
      dec: {d: -30, m: 28, s: 47.5}
    },
    {
      number: 55,
      ngc: 6809,
      name: nil,
      type: :globular_cluster,
      constellation: :sgr,
      magnitude: 6.3,
      size: {major_arcminutes: 19},
      distance_ly: 17600,
      ra: {h: 19, m: 39, s: 59.71},
      dec: {d: -30, m: 57, s: 53.1}
    },
    {
      number: 56,
      ngc: 6779,
      name: nil,
      type: :globular_cluster,
      constellation: :lyr,
      magnitude: 8.3,
      size: {major_arcminutes: 8.8},
      distance_ly: 32900,
      ra: {h: 19, m: 16, s: 35.57},
      dec: {d: 30, m: 11, s: 0.5}
    },
    {
      number: 57,
      ngc: 6720,
      name: "Ring Nebula",
      type: :planetary_nebula,
      constellation: :lyr,
      magnitude: 8.8,
      size: {major_arcminutes: 1.4, minor_arcminutes: 1},
      distance_ly: 2300,
      ra: {h: 18, m: 53, s: 35.08},
      dec: {d: 33, m: 1, s: 45.0}
    },
    {
      number: 58,
      ngc: 4579,
      name: nil,
      type: :spiral_galaxy,
      constellation: :vir,
      magnitude: 9.7,
      size: {major_arcminutes: 5.5, minor_arcminutes: 4.5},
      distance_ly: 62000000,
      ra: {h: 12, m: 37, s: 43.5},
      dec: {d: 11, m: 49, s: 5.0}
    },
    {
      number: 59,
      ngc: 4621,
      name: nil,
      type: :elliptical_galaxy,
      constellation: :vir,
      magnitude: 9.6,
      size: {major_arcminutes: 5, minor_arcminutes: 3.5},
      distance_ly: 60000000,
      ra: {h: 12, m: 42, s: 2.3},
      dec: {d: 11, m: 38, s: 49.0}
    },
    {
      number: 60,
      ngc: 4649,
      name: nil,
      type: :elliptical_galaxy,
      constellation: :vir,
      magnitude: 8.8,
      size: {major_arcminutes: 7, minor_arcminutes: 6},
      distance_ly: 55000000,
      ra: {h: 12, m: 43, s: 39.6},
      dec: {d: 11, m: 33, s: 9.0}
    },
    {
      number: 61,
      ngc: 4303,
      name: nil,
      type: :spiral_galaxy,
      constellation: :vir,
      magnitude: 9.7,
      size: {major_arcminutes: 6, minor_arcminutes: 5.5},
      distance_ly: 52500000,
      ra: {h: 12, m: 21, s: 54.9},
      dec: {d: 4, m: 28, s: 25.0}
    },
    {
      number: 62,
      ngc: 6266,
      name: nil,
      type: :globular_cluster,
      constellation: :oph,
      magnitude: 6.4,
      size: {major_arcminutes: 15},
      distance_ly: 22500,
      ra: {h: 17, m: 1, s: 12.60},
      dec: {d: -30, m: 6, s: 44.5}
    },
    {
      number: 63,
      ngc: 5055,
      name: "Sunflower Galaxy",
      type: :spiral_galaxy,
      constellation: :cvn,
      magnitude: 8.6,
      size: {major_arcminutes: 12.6, minor_arcminutes: 7.2},
      distance_ly: 37000000,
      ra: {h: 13, m: 15, s: 49.3},
      dec: {d: 42, m: 1, s: 45.0}
    },
    {
      number: 64,
      ngc: 4826,
      name: "Black Eye Galaxy",
      type: :spiral_galaxy,
      constellation: :com,
      magnitude: 8.5,
      size: {major_arcminutes: 10, minor_arcminutes: 5},
      distance_ly: 24000000,
      ra: {h: 12, m: 56, s: 43.7},
      dec: {d: 21, m: 40, s: 58.0}
    },
    {
      number: 65,
      ngc: 3623,
      name: nil,
      type: :spiral_galaxy,
      constellation: :leo,
      magnitude: 9.3,
      size: {major_arcminutes: 10, minor_arcminutes: 3},
      distance_ly: 35000000,
      ra: {h: 11, m: 18, s: 55.9},
      dec: {d: 13, m: 5, s: 32.0}
    },
    {
      number: 66,
      ngc: 3627,
      name: nil,
      type: :spiral_galaxy,
      constellation: :leo,
      magnitude: 8.9,
      size: {major_arcminutes: 9, minor_arcminutes: 4},
      distance_ly: 35000000,
      ra: {h: 11, m: 20, s: 15.0},
      dec: {d: 12, m: 59, s: 30.0}
    },
    {
      number: 67,
      ngc: 2682,
      name: nil,
      type: :open_cluster,
      constellation: :cnc,
      magnitude: 6.9,
      size: {major_arcminutes: 30},
      distance_ly: 2700,
      ra: {h: 8, m: 51, s: 18.0},
      dec: {d: 11, m: 48, s: 0.0}
    },
    {
      number: 68,
      ngc: 4590,
      name: nil,
      type: :globular_cluster,
      constellation: :hya,
      magnitude: 7.8,
      size: {major_arcminutes: 11},
      distance_ly: 33300,
      ra: {h: 12, m: 39, s: 27.98},
      dec: {d: -26, m: 44, s: 38.6}
    },
    {
      number: 69,
      ngc: 6637,
      name: nil,
      type: :globular_cluster,
      constellation: :sgr,
      magnitude: 7.6,
      size: {major_arcminutes: 9.8},
      distance_ly: 29700,
      ra: {h: 18, m: 31, s: 23.10},
      dec: {d: -32, m: 20, s: 53.1}
    },
    {
      number: 70,
      ngc: 6681,
      name: nil,
      type: :globular_cluster,
      constellation: :sgr,
      magnitude: 8.0,
      size: {major_arcminutes: 8},
      distance_ly: 29400,
      ra: {h: 18, m: 43, s: 12.76},
      dec: {d: -32, m: 17, s: 31.6}
    },
    {
      number: 71,
      ngc: 6838,
      name: nil,
      type: :globular_cluster,
      constellation: :sge,
      magnitude: 8.2,
      size: {major_arcminutes: 7.2},
      distance_ly: 13000,
      ra: {h: 19, m: 53, s: 46.49},
      dec: {d: 18, m: 46, s: 45.1}
    },
    {
      number: 72,
      ngc: 6981,
      name: nil,
      type: :globular_cluster,
      constellation: :aqr,
      magnitude: 9.3,
      size: {major_arcminutes: 6.6},
      distance_ly: 53400,
      ra: {h: 20, m: 53, s: 27.70},
      dec: {d: -12, m: 32, s: 13.3}
    },
    {
      number: 73,
      ngc: 6994,
      name: nil,
      type: :asterism,
      constellation: :aqr,
      magnitude: 9.0,
      size: {major_arcminutes: 2.8},
      distance_ly: 2500,
      ra: {h: 20, m: 58, s: 56.0},
      dec: {d: -12, m: 38, s: 0.0}
    },
    {
      number: 74,
      ngc: 628,
      name: nil,
      type: :spiral_galaxy,
      constellation: :psc,
      magnitude: 9.4,
      size: {major_arcminutes: 10.5, minor_arcminutes: 9.5},
      distance_ly: 30000000,
      ra: {h: 1, m: 36, s: 41.8},
      dec: {d: 15, m: 47, s: 0.0}
    },
    {
      number: 75,
      ngc: 6864,
      name: nil,
      type: :globular_cluster,
      constellation: :sgr,
      magnitude: 8.5,
      size: {major_arcminutes: 6},
      distance_ly: 67500,
      ra: {h: 20, m: 6, s: 4.75},
      dec: {d: -21, m: 55, s: 16.9}
    },
    {
      number: 76,
      ngc: 650,
      name: "Little Dumbbell Nebula",
      type: :planetary_nebula,
      constellation: :per,
      magnitude: 10.1,
      size: {major_arcminutes: 2.7, minor_arcminutes: 1.8},
      distance_ly: 2500,
      ra: {h: 1, m: 42, s: 19.69},
      dec: {d: 51, m: 34, s: 31.7}
    },
    {
      number: 77,
      ngc: 1068,
      name: nil,
      type: :spiral_galaxy,
      constellation: :cet,
      magnitude: 8.9,
      size: {major_arcminutes: 7, minor_arcminutes: 6},
      distance_ly: 47000000,
      ra: {h: 2, m: 42, s: 40.7},
      dec: {sign: -1, d: 0, m: 0, s: 48.0}
    },
    {
      number: 78,
      ngc: 2068,
      name: nil,
      type: :reflection_nebula,
      constellation: :ori,
      magnitude: 8.3,
      size: {major_arcminutes: 8, minor_arcminutes: 6},
      distance_ly: 1600,
      ra: {h: 5, m: 46, s: 45.8},
      dec: {d: 0, m: 4, s: 45.0}
    },
    {
      number: 79,
      ngc: 1904,
      name: nil,
      type: :globular_cluster,
      constellation: :lep,
      magnitude: 7.7,
      size: {major_arcminutes: 9.6},
      distance_ly: 42100,
      ra: {h: 5, m: 24, s: 10.59},
      dec: {d: -24, m: 31, s: 27.3}
    },
    {
      number: 80,
      ngc: 6093,
      name: nil,
      type: :globular_cluster,
      constellation: :sco,
      magnitude: 7.3,
      size: {major_arcminutes: 10},
      distance_ly: 32600,
      ra: {h: 16, m: 17, s: 2.41},
      dec: {d: -22, m: 58, s: 33.9}
    },
    {
      number: 81,
      ngc: 3031,
      name: "Bode's Galaxy",
      type: :spiral_galaxy,
      constellation: :uma,
      magnitude: 6.9,
      size: {major_arcminutes: 26, minor_arcminutes: 14},
      distance_ly: 11800000,
      ra: {h: 9, m: 55, s: 33.2},
      dec: {d: 69, m: 3, s: 55.0}
    },
    {
      number: 82,
      ngc: 3034,
      name: "Cigar Galaxy",
      type: :irregular_galaxy,
      constellation: :uma,
      magnitude: 8.4,
      size: {major_arcminutes: 11, minor_arcminutes: 4.3},
      distance_ly: 11500000,
      ra: {h: 9, m: 55, s: 52.2},
      dec: {d: 69, m: 40, s: 47.0}
    },
    {
      number: 83,
      ngc: 5236,
      name: "Southern Pinwheel Galaxy",
      type: :spiral_galaxy,
      constellation: :hya,
      magnitude: 7.6,
      size: {major_arcminutes: 13, minor_arcminutes: 12},
      distance_ly: 15000000,
      ra: {h: 13, m: 37, s: 0.9},
      dec: {d: -29, m: 51, s: 57.0}
    },
    {
      number: 84,
      ngc: 4374,
      name: nil,
      type: :lenticular_galaxy,
      constellation: :vir,
      magnitude: 9.1,
      size: {major_arcminutes: 6.5, minor_arcminutes: 5.6},
      distance_ly: 60000000,
      ra: {h: 12, m: 25, s: 3.7},
      dec: {d: 12, m: 53, s: 13.0}
    },
    {
      number: 85,
      ngc: 4382,
      name: nil,
      type: :lenticular_galaxy,
      constellation: :com,
      magnitude: 9.1,
      size: {major_arcminutes: 7.1, minor_arcminutes: 5.5},
      distance_ly: 60000000,
      ra: {h: 12, m: 25, s: 24.0},
      dec: {d: 18, m: 11, s: 28.0}
    },
    {
      number: 86,
      ngc: 4406,
      name: nil,
      type: :lenticular_galaxy,
      constellation: :vir,
      magnitude: 8.9,
      size: {major_arcminutes: 8.9, minor_arcminutes: 5.8},
      distance_ly: 52000000,
      ra: {h: 12, m: 26, s: 11.7},
      dec: {d: 12, m: 56, s: 46.0}
    },
    {
      number: 87,
      ngc: 4486,
      name: "Virgo A",
      type: :elliptical_galaxy,
      constellation: :vir,
      magnitude: 8.6,
      size: {major_arcminutes: 8.3, minor_arcminutes: 6.6},
      distance_ly: 53500000,
      ra: {h: 12, m: 30, s: 49.4},
      dec: {d: 12, m: 23, s: 28.0}
    },
    {
      number: 88,
      ngc: 4501,
      name: nil,
      type: :spiral_galaxy,
      constellation: :com,
      magnitude: 9.6,
      size: {major_arcminutes: 7, minor_arcminutes: 4},
      distance_ly: 47000000,
      ra: {h: 12, m: 32, s: 0.0},
      dec: {d: 14, m: 25, s: 13.0}
    },
    {
      number: 89,
      ngc: 4552,
      name: nil,
      type: :elliptical_galaxy,
      constellation: :vir,
      magnitude: 9.8,
      size: {major_arcminutes: 5.1, minor_arcminutes: 4.7},
      distance_ly: 50000000,
      ra: {h: 12, m: 35, s: 39.8},
      dec: {d: 12, m: 33, s: 23.0}
    },
    {
      number: 90,
      ngc: 4569,
      name: nil,
      type: :spiral_galaxy,
      constellation: :vir,
      magnitude: 9.5,
      size: {major_arcminutes: 9.5, minor_arcminutes: 4.7},
      distance_ly: 58700000,
      ra: {h: 12, m: 36, s: 49.8},
      dec: {d: 13, m: 9, s: 46.0}
    },
    {
      number: 91,
      ngc: 4548,
      name: nil,
      type: :spiral_galaxy,
      constellation: :com,
      magnitude: 10.2,
      size: {major_arcminutes: 5.4, minor_arcminutes: 4.4},
      distance_ly: 63000000,
      ra: {h: 12, m: 35, s: 26.4},
      dec: {d: 14, m: 29, s: 47.0}
    },
    {
      number: 92,
      ngc: 6341,
      name: nil,
      type: :globular_cluster,
      constellation: :her,
      magnitude: 6.3,
      size: {major_arcminutes: 14},
      distance_ly: 26700,
      ra: {h: 17, m: 17, s: 7.39},
      dec: {d: 43, m: 8, s: 9.4}
    },
    {
      number: 93,
      ngc: 2447,
      name: nil,
      type: :open_cluster,
      constellation: :pup,
      magnitude: 6.2,
      size: {major_arcminutes: 22},
      distance_ly: 3600,
      ra: {h: 7, m: 44, s: 30.0},
      dec: {d: -23, m: 51, s: 24.0}
    },
    {
      number: 94,
      ngc: 4736,
      name: nil,
      type: :spiral_galaxy,
      constellation: :cvn,
      magnitude: 8.2,
      size: {major_arcminutes: 11, minor_arcminutes: 9},
      distance_ly: 16000000,
      ra: {h: 12, m: 50, s: 53.1},
      dec: {d: 41, m: 7, s: 14.0}
    },
    {
      number: 95,
      ngc: 3351,
      name: nil,
      type: :spiral_galaxy,
      constellation: :leo,
      magnitude: 9.7,
      size: {major_arcminutes: 7.4, minor_arcminutes: 5},
      distance_ly: 32600000,
      ra: {h: 10, m: 43, s: 57.7},
      dec: {d: 11, m: 42, s: 14.0}
    },
    {
      number: 96,
      ngc: 3368,
      name: nil,
      type: :spiral_galaxy,
      constellation: :leo,
      magnitude: 9.2,
      size: {major_arcminutes: 7.6, minor_arcminutes: 5.2},
      distance_ly: 31000000,
      ra: {h: 10, m: 46, s: 45.7},
      dec: {d: 11, m: 49, s: 12.0}
    },
    {
      number: 97,
      ngc: 3587,
      name: "Owl Nebula",
      type: :planetary_nebula,
      constellation: :uma,
      magnitude: 9.9,
      size: {major_arcminutes: 3.4, minor_arcminutes: 3.3},
      distance_ly: 2030,
      ra: {h: 11, m: 14, s: 47.73},
      dec: {d: 55, m: 1, s: 8.5}
    },
    {
      number: 98,
      ngc: 4192,
      name: nil,
      type: :spiral_galaxy,
      constellation: :com,
      magnitude: 10.1,
      size: {major_arcminutes: 9.5, minor_arcminutes: 3.2},
      distance_ly: 44400000,
      ra: {h: 12, m: 13, s: 48.3},
      dec: {d: 14, m: 54, s: 1.0}
    },
    {
      number: 99,
      ngc: 4254,
      name: nil,
      type: :spiral_galaxy,
      constellation: :com,
      magnitude: 9.9,
      size: {major_arcminutes: 5.4, minor_arcminutes: 4.8},
      distance_ly: 55000000,
      ra: {h: 12, m: 18, s: 49.6},
      dec: {d: 14, m: 25, s: 0.0}
    },
    {
      number: 100,
      ngc: 4321,
      name: nil,
      type: :spiral_galaxy,
      constellation: :com,
      magnitude: 9.3,
      size: {major_arcminutes: 7.4, minor_arcminutes: 6.3},
      distance_ly: 55000000,
      ra: {h: 12, m: 22, s: 54.9},
      dec: {d: 15, m: 49, s: 21.0}
    },
    {
      number: 101,
      ngc: 5457,
      name: "Pinwheel Galaxy",
      type: :spiral_galaxy,
      constellation: :uma,
      magnitude: 7.9,
      size: {major_arcminutes: 29, minor_arcminutes: 27},
      distance_ly: 21000000,
      ra: {h: 14, m: 3, s: 12.6},
      dec: {d: 54, m: 20, s: 57.0}
    },
    {
      number: 102,
      ngc: 5866,
      name: "Spindle Galaxy",
      type: :lenticular_galaxy,
      constellation: :dra,
      magnitude: 9.9,
      size: {major_arcminutes: 5.8, minor_arcminutes: 3.1},
      distance_ly: 50000000,
      ra: {h: 15, m: 6, s: 29.5},
      dec: {d: 55, m: 45, s: 48.0}
    },
    {
      number: 103,
      ngc: 581,
      name: nil,
      type: :open_cluster,
      constellation: :cas,
      magnitude: 7.4,
      size: {major_arcminutes: 6},
      distance_ly: 8500,
      ra: {h: 1, m: 33, s: 23.0},
      dec: {d: 60, m: 39, s: 0.0}
    },
    {
      number: 104,
      ngc: 4594,
      name: "Sombrero Galaxy",
      type: :spiral_galaxy,
      constellation: :vir,
      magnitude: 8.0,
      size: {major_arcminutes: 8.7, minor_arcminutes: 3.5},
      distance_ly: 29350000,
      ra: {h: 12, m: 39, s: 59.4},
      dec: {d: -11, m: 37, s: 23.0}
    },
    {
      number: 105,
      ngc: 3379,
      name: nil,
      type: :elliptical_galaxy,
      constellation: :leo,
      magnitude: 9.3,
      size: {major_arcminutes: 5.4, minor_arcminutes: 4.8},
      distance_ly: 32000000,
      ra: {h: 10, m: 47, s: 49.6},
      dec: {d: 12, m: 34, s: 54.0}
    },
    {
      number: 106,
      ngc: 4258,
      name: nil,
      type: :spiral_galaxy,
      constellation: :cvn,
      magnitude: 8.4,
      size: {major_arcminutes: 19, minor_arcminutes: 8},
      distance_ly: 23500000,
      ra: {h: 12, m: 18, s: 57.5},
      dec: {d: 47, m: 18, s: 14.0}
    },
    {
      number: 107,
      ngc: 6171,
      name: nil,
      type: :globular_cluster,
      constellation: :oph,
      magnitude: 7.9,
      size: {major_arcminutes: 13},
      distance_ly: 20900,
      ra: {h: 16, m: 32, s: 31.86},
      dec: {d: -13, m: 3, s: 13.6}
    },
    {
      number: 108,
      ngc: 3556,
      name: nil,
      type: :spiral_galaxy,
      constellation: :uma,
      magnitude: 10.0,
      size: {major_arcminutes: 8.7, minor_arcminutes: 2.2},
      distance_ly: 45000000,
      ra: {h: 11, m: 11, s: 31.0},
      dec: {d: 55, m: 40, s: 27.0}
    },
    {
      number: 109,
      ngc: 3992,
      name: nil,
      type: :spiral_galaxy,
      constellation: :uma,
      magnitude: 9.8,
      size: {major_arcminutes: 7.6, minor_arcminutes: 4.7},
      distance_ly: 83500000,
      ra: {h: 11, m: 57, s: 36.0},
      dec: {d: 53, m: 22, s: 28.0}
    },
    {
      number: 110,
      ngc: 205,
      name: nil,
      type: :elliptical_galaxy,
      constellation: :and,
      magnitude: 8.1,
      size: {major_arcminutes: 21.9, minor_arcminutes: 11},
      distance_ly: 2690000,
      ra: {h: 0, m: 40, s: 22.1},
      dec: {d: 41, m: 41, s: 7.0}
    }
  ].freeze

  NGC_OBJECTS = [
    {
      number: 104,
      name: "47 Tucanae",
      type: :globular_cluster,
      constellation: :tuc,
      magnitude: 4.09,
      size: {major_arcminutes: 43.8},
      distance_ly: 13000,
      ra: {h: 0, m: 24, s: 5.4},
      dec: {d: -72, m: 4, s: 53.2}
    },
    {
      number: 253,
      name: "Sculptor Galaxy",
      type: :spiral_galaxy,
      constellation: :scl,
      magnitude: 7.2,
      size: {major_arcminutes: 27, minor_arcminutes: 5.89},
      distance_ly: 11400000,
      ra: {h: 0, m: 47, s: 33.1},
      dec: {d: -25, m: 17, s: 19.7}
    },
    {
      number: 869,
      name: "Double Cluster",
      type: :open_cluster,
      constellation: :per,
      magnitude: 5.3,
      size: {major_arcminutes: 16.3},
      distance_ly: 7500,
      ra: {h: 2, m: 18, s: 57.8},
      dec: {d: 57, m: 8, s: 2.0}
    },
    {
      number: 884,
      name: nil,
      type: :open_cluster,
      constellation: :per,
      magnitude: 6.1,
      size: {major_arcminutes: 15},
      distance_ly: 7600,
      ra: {h: 2, m: 22, s: 20.2},
      dec: {d: 57, m: 8, s: 56.0}
    },
    {
      number: 891,
      name: nil,
      type: :spiral_galaxy,
      constellation: :and,
      magnitude: 10.0,
      size: {major_arcminutes: 13.5, minor_arcminutes: 3.03},
      distance_ly: 30000000,
      ra: {h: 2, m: 22, s: 33.4},
      dec: {d: 42, m: 20, s: 57.0}
    },
    {
      number: 2070,
      name: "Tarantula Nebula",
      type: :nebula_with_cluster,
      constellation: :dor,
      magnitude: 7.25,
      size: {major_arcminutes: 40, minor_arcminutes: 25},
      distance_ly: 160000,
      ra: {h: 5, m: 38, s: 42.0},
      dec: {d: -69, m: 6, s: 0.0}
    },
    {
      number: 2516,
      name: nil,
      type: :open_cluster,
      constellation: :car,
      magnitude: 3.8,
      size: {major_arcminutes: 30},
      distance_ly: 1340,
      ra: {h: 7, m: 58, s: 4.0},
      dec: {d: -60, m: 45, s: 12.0}
    },
    {
      number: 3372,
      name: "Carina Nebula",
      type: :nebula_with_cluster,
      constellation: :car,
      magnitude: 1.0,
      size: {major_arcminutes: 120, minor_arcminutes: 120},
      distance_ly: 7500,
      ra: {h: 10, m: 45, s: 8.5},
      dec: {d: -59, m: 52, s: 4.0}
    },
    {
      number: 3532,
      name: "Wishing Well Cluster",
      type: :open_cluster,
      constellation: :car,
      magnitude: 3.0,
      size: {major_arcminutes: 55},
      distance_ly: 1320,
      ra: {h: 11, m: 5, s: 40.1},
      dec: {d: -58, m: 42, s: 25.0}
    },
    {
      number: 3766,
      name: "Pearl Cluster",
      type: :open_cluster,
      constellation: :cen,
      magnitude: 5.3,
      size: {major_arcminutes: 12},
      distance_ly: 5500,
      ra: {h: 11, m: 36, s: 14.6},
      dec: {d: -61, m: 36, s: 58.0}
    },
    {
      number: 4755,
      name: "Jewel Box",
      type: :open_cluster,
      constellation: :cru,
      magnitude: 4.2,
      size: {major_arcminutes: 10},
      distance_ly: 6400,
      ra: {h: 12, m: 53, s: 39.6},
      dec: {d: -60, m: 22, s: 16.0}
    },
    {
      number: 4945,
      name: nil,
      type: :spiral_galaxy,
      constellation: :cen,
      magnitude: 8.7,
      size: {major_arcminutes: 20, minor_arcminutes: 4},
      distance_ly: 11700000,
      ra: {h: 13, m: 5, s: 27.3},
      dec: {d: -49, m: 28, s: 4.4}
    },
    {
      number: 5128,
      name: "Centaurus A",
      type: :elliptical_galaxy,
      constellation: :cen,
      magnitude: 6.8,
      size: {major_arcminutes: 25, minor_arcminutes: 20},
      distance_ly: 12000000,
      ra: {h: 13, m: 25, s: 27.6},
      dec: {d: -43, m: 1, s: 9.0}
    },
    {
      number: 5139,
      name: "Omega Centauri",
      type: :globular_cluster,
      constellation: :cen,
      magnitude: 3.9,
      size: {major_arcminutes: 36},
      distance_ly: 15800,
      ra: {h: 13, m: 26, s: 47.3},
      dec: {d: -47, m: 28, s: 46.1}
    },
    {
      number: 6231,
      name: nil,
      type: :open_cluster,
      constellation: :sco,
      magnitude: 2.6,
      size: {major_arcminutes: 14},
      distance_ly: 5900,
      ra: {h: 16, m: 54, s: 10.0},
      dec: {d: -41, m: 49, s: 30.0}
    },
    {
      number: 6397,
      name: nil,
      type: :globular_cluster,
      constellation: :ara,
      magnitude: 5.17,
      size: {major_arcminutes: 25.7},
      distance_ly: 7800,
      ra: {h: 17, m: 40, s: 42.1},
      dec: {d: -53, m: 40, s: 27.6}
    },
    {
      number: 6752,
      name: nil,
      type: :globular_cluster,
      constellation: :pav,
      magnitude: 5.4,
      size: {major_arcminutes: 20.4},
      distance_ly: 13000,
      ra: {h: 19, m: 10, s: 52.1},
      dec: {d: -59, m: 59, s: 4.4}
    },
    {
      number: 7000,
      name: "North America Nebula",
      type: :nebula,
      constellation: :cyg,
      magnitude: 4.0,
      size: {major_arcminutes: 120, minor_arcminutes: 100},
      distance_ly: 2200,
      ra: {h: 20, m: 58, s: 47.0},
      dec: {d: 44, m: 19, s: 48.0}
    }
  ].freeze

  def self.all
    MESSIER_OBJECTS.map { |data| build(data, :messier) } +
      NGC_OBJECTS.map { |data| build(data, :ngc) }
  end

  def self.find_by_designation(designation)
    all.find { |object| object.designation == designation }
  end

  def self.find_all_by_designation(designations)
    index = all.index_by(&:designation)

    designations.filter_map { |designation| index[designation] }
  end

  def self.designation_for(catalog, number)
    (catalog == :ngc) ? "NGC #{number}" : "M#{number}"
  end

  def self.notability(designation)
    return :showpiece if SHOWPIECES.include?(designation)
    return :notable if NOTABLE.include?(designation)
    return :faint if FAINT.include?(designation)

    :ordinary
  end

  def self.instrument(designation)
    return :naked_eye if NAKED_EYE.include?(designation)
    return :binoculars if BINOCULARS.include?(designation)
    return :large_telescope if LARGE_TELESCOPE.include?(designation)

    :small_telescope
  end

  def self.declination(parts)
    magnitude =
      parts[:d].abs + parts[:m] / 60.0 + parts[:s] / 3600.0
    sign = parts[:sign] || (parts[:d].negative? ? -1 : 1)

    Astronoby::Angle.from_degrees(sign * magnitude)
  end

  def self.arcminutes(value)
    Astronoby::Angle.from_degrees(value / 60.0)
  end

  def self.build(data, catalog)
    designation = designation_for(catalog, data[:number])

    DeepSkyObject.new(
      number: data[:number],
      catalog: catalog,
      notability: notability(designation),
      instrument: instrument(designation),
      ngc_number: (catalog == :ngc) ? data[:number] : data[:ngc],
      name: data[:name],
      type: data[:type],
      constellation: Constellation.find_by_abbreviation(data[:constellation]),
      magnitude: data[:magnitude],
      major_axis: arcminutes(data.dig(:size, :major_arcminutes)),
      minor_axis: arcminutes(
        data.dig(:size, :minor_arcminutes) ||
          data.dig(:size, :major_arcminutes)
      ),
      j2000_coordinates: Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(
          data.dig(:ra, :h),
          data.dig(:ra, :m),
          data.dig(:ra, :s)
        ),
        declination: declination(data[:dec]),
        epoch: Astronoby::JulianDate::J2000
      ),
      distance: data[:distance_ly]
    )
  end
end
