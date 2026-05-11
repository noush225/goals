// icons.jsx — hand-tuned line icons for Momentum
// All icons accept { size, color, stroke } and render at currentColor by default.

const Icon = ({ children, size = 24, viewBox = '0 0 24 24', style }) => (
  <svg width={size} height={size} viewBox={viewBox} fill="none"
       stroke="currentColor" strokeWidth="1.6"
       strokeLinecap="round" strokeLinejoin="round" style={style}>
    {children}
  </svg>
);

const IGear = (p) => (
  <Icon {...p}>
    <circle cx="12" cy="12" r="3" />
    <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09a1.65 1.65 0 0 0-1-1.51 1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09a1.65 1.65 0 0 0 1.51-1 1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33h0a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51h0a1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82v0a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" />
  </Icon>
);

const IPlus = (p) => (
  <Icon {...p}><path d="M12 5v14M5 12h14" strokeWidth="2" /></Icon>
);

const IPlay = (p) => (
  <Icon {...p}><path d="M8 5.5v13a.5.5 0 0 0 .77.42l10-6.5a.5.5 0 0 0 0-.84l-10-6.5A.5.5 0 0 0 8 5.5z"
        fill="currentColor" stroke="none" /></Icon>
);

const IPause = (p) => (
  <Icon {...p}>
    <rect x="7" y="5" width="3.4" height="14" rx="1" fill="currentColor" stroke="none" />
    <rect x="13.6" y="5" width="3.4" height="14" rx="1" fill="currentColor" stroke="none" />
  </Icon>
);

// One-shot — a single target dot
const ITarget = (p) => (
  <Icon {...p}>
    <circle cx="12" cy="12" r="8.5" strokeWidth="1.4" />
    <circle cx="12" cy="12" r="3.2" fill="currentColor" stroke="none" />
  </Icon>
);

// Progression — stepped bars
const ISteps = (p) => (
  <Icon {...p}>
    <path d="M4 17h3v3M9.5 13.5h3v6.5M15 9.5h3v10.5" strokeWidth="1.6" />
    <circle cx="5.5" cy="17" r="0.1" />
  </Icon>
);

const IChevronLeft = (p) => (
  <Icon {...p}><path d="M15 6l-6 6 6 6" strokeWidth="1.8" /></Icon>
);
const IChevronRight = (p) => (
  <Icon {...p}><path d="M9 6l6 6-6 6" strokeWidth="1.8" /></Icon>
);
const IChevronDown = (p) => (
  <Icon {...p}><path d="M6 9l6 6 6-6" strokeWidth="1.8" /></Icon>
);

const IX = (p) => (
  <Icon {...p}><path d="M6 6l12 12M18 6L6 18" strokeWidth="2" /></Icon>
);

const ICheck = (p) => (
  <Icon {...p}><path d="M5 12.5l4.5 4.5L19 7" strokeWidth="2" /></Icon>
);

const ICalendar = (p) => (
  <Icon {...p}>
    <rect x="3.5" y="5" width="17" height="15.5" rx="2.5" />
    <path d="M3.5 10h17M8 3.5v3M16 3.5v3" />
  </Icon>
);

const IMusic = (p) => (
  <Icon {...p}>
    <path d="M9 17V5l11-1.5v11" />
    <circle cx="7" cy="17" r="2.2" fill="currentColor" stroke="none" />
    <circle cx="18" cy="14.5" r="2.2" fill="currentColor" stroke="none" />
  </Icon>
);

const ISpeaker = (p) => (
  <Icon {...p}>
    <path d="M11 5L6.5 9H3v6h3.5L11 19V5z" fill="currentColor" stroke="currentColor" />
    <path d="M15 9.5c1 .8 1.5 1.7 1.5 2.5s-.5 1.7-1.5 2.5M18 6.5c2 1.5 3 3.4 3 5.5s-1 4-3 5.5" />
  </Icon>
);

const IMute = (p) => (
  <Icon {...p}>
    <path d="M11 5L6.5 9H3v6h3.5L11 19V5z" fill="currentColor" stroke="currentColor" />
    <path d="M16 9l5 6M21 9l-5 6" />
  </Icon>
);

const IBell = (p) => (
  <Icon {...p}>
    <path d="M6 8.5a6 6 0 1 1 12 0v3l1.5 3.5h-15L6 11.5v-3z" />
    <path d="M10 18.5a2 2 0 0 0 4 0" />
  </Icon>
);

const IGlobe = (p) => (
  <Icon {...p}>
    <circle cx="12" cy="12" r="8.5" />
    <path d="M3.5 12h17M12 3.5c2.5 2.5 4 5.6 4 8.5s-1.5 6-4 8.5M12 3.5c-2.5 2.5-4 5.6-4 8.5s1.5 6 4 8.5" />
  </Icon>
);

// Tiny dot used as a separator
const Dot = ({ size = 3, color = 'currentColor', opacity = 0.4 }) => (
  <span style={{
    display: 'inline-block', width: size, height: size, borderRadius: '50%',
    background: color, opacity, verticalAlign: 'middle', margin: '0 8px',
  }} />
);

Object.assign(window, {
  IGear, IPlus, IPlay, IPause, ITarget, ISteps,
  IChevronLeft, IChevronRight, IChevronDown,
  IX, ICheck, ICalendar, IMusic, ISpeaker, IMute, IBell, IGlobe, Dot,
});
