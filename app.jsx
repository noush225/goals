// app.jsx — Momentum root app. Wires screens together, owns tasks state, integrates Tweaks.

const { useState: useS } = React;

// Theme builder — composes a flat `T` object from the current palette + font.
function buildTheme(palette, font) {
  // palette: { bg, surface, surfaceSunk, ink, inkSoft, muted, accent, accentLight, accentShadow, inkShadow, hairline }
  // focus subtheme is the same for all (dark immersive); accent shifts hue
  return {
    font,
    ...palette,
    focus: {
      bg: '#14181A',
      ink: '#EAE6DA',
      inkSoft: 'rgba(234,230,218,0.7)',
      muted: 'rgba(234,230,218,0.45)',
      accent: palette.focusAccent || '#A8BFA1',
      timer: palette.focusAccent ? '#F2EFE6' : '#F2EFE6',
      timerGlow: `${palette.focusAccent || '#A8BFA1'}55`,
      glow: `${palette.focusAccent || '#A8BFA1'}22`,
      ring: 'rgba(234,230,218,0.08)',
      ringFaint: 'rgba(234,230,218,0.04)',
    },
  };
}

const PALETTES = {
  sage: {
    name: 'Sage',
    bg: '#F4F1EA',
    surface: '#FBF9F4',
    surfaceSunk: '#EDE9DF',
    ink: '#2D3A2E',
    inkSoft: '#5A6660',
    muted: '#9A968C',
    accent: '#6B8268',
    accentLight: '#A8BFA1',
    accentShadow: 'rgba(107,130,104,0.4)',
    inkShadow: 'rgba(45,58,46,0.35)',
    hairline: 'rgba(45,58,46,0.08)',
    focusAccent: '#A8BFA1',
  },
  mist: {
    name: 'Mist',
    bg: '#F1F3F5',
    surface: '#FBFCFD',
    surfaceSunk: '#E8ECEF',
    ink: '#1F2937',
    inkSoft: '#4B5563',
    muted: '#94A0AE',
    accent: '#5B7A99',
    accentLight: '#A6BBCF',
    accentShadow: 'rgba(91,122,153,0.4)',
    inkShadow: 'rgba(31,41,55,0.35)',
    hairline: 'rgba(31,41,55,0.08)',
    focusAccent: '#A6BBCF',
  },
  clay: {
    name: 'Clay',
    bg: '#F6F1EC',
    surface: '#FBF7F2',
    surfaceSunk: '#EDE5DC',
    ink: '#2A2421',
    inkSoft: '#5A4F48',
    muted: '#9C9087',
    accent: '#B8755C',
    accentLight: '#DBA992',
    accentShadow: 'rgba(184,117,92,0.4)',
    inkShadow: 'rgba(42,36,33,0.35)',
    hairline: 'rgba(42,36,33,0.08)',
    focusAccent: '#DBA992',
  },
};

const FONTS = {
  Manrope: '"Manrope", ui-sans-serif, system-ui, sans-serif',
  'Inter Tight': '"Inter Tight", ui-sans-serif, system-ui, sans-serif',
  Geist: '"Geist", ui-sans-serif, system-ui, sans-serif',
};

const SEED_TASKS = [
  { id: 1, title: 'Storyboard the opening sequence', type: 'progression', progress: 60, minutes: 215, subtasks: '6 of 10 scenes' },
  { id: 2, title: 'Sketch hero illustration for blog', type: 'oneshot', progress: 0, minutes: 0 },
  { id: 3, title: 'Edit chapter three of the novel', type: 'progression', progress: 35, minutes: 142, subtasks: 'Pages 48–60' },
  { id: 4, title: 'Record voice memo for podcast intro', type: 'oneshot', progress: 100, minutes: 28 },
  { id: 5, title: 'Color-grade the wedding reel', type: 'progression', progress: 15, minutes: 47, subtasks: 'Act 1 of 3' },
];

function App() {
  const [tw, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const palette = PALETTES[tw.palette] || PALETTES.sage;
  const font = FONTS[tw.font] || FONTS.Manrope;
  const T = buildTheme(palette, font);

  const [tab, setTab] = useS('today');
  const [tasks, setTasks] = useS(SEED_TASKS);
  const [addOpen, setAddOpen] = useS(false);
  const [settingsOpen, setSettingsOpen] = useS(false);
  const [focusTask, setFocusTask] = useS(null);

  function handleAddSave(payload) {
    setTasks(prev => [
      { id: Date.now(), title: payload.title, type: payload.type, progress: payload.type === 'progression' ? payload.progress : 0, minutes: 0 },
      ...prev,
    ]);
    setAddOpen(false);
  }

  function handleFinish(sec) {
    const mins = Math.max(1, Math.round(sec / 60));
    setTasks(prev => prev.map(t => t.id === focusTask.id ? { ...t, minutes: t.minutes + mins } : t));
    setFocusTask(null);
  }

  const isFocus = !!focusTask;

  return (
    <div style={{ fontFamily: T.font, color: T.ink }}>
      <IOSDevice dark={isFocus} width={390} height={844}>
        <div style={{ position: 'relative', width: '100%', height: '100%', overflow: 'hidden' }}>
          <HomeScreen
            tasks={tab === 'today' ? tasks.slice(0, 4) : tasks}
            tab={tab} onTab={setTab}
            onAdd={() => setAddOpen(true)}
            onPlay={(t) => setFocusTask(t)}
            onSettings={() => setSettingsOpen(true)}
            T={T}
          />
          <AddTaskSheet
            open={addOpen}
            onClose={() => setAddOpen(false)}
            onSave={handleAddSave}
            tasks={tasks}
            T={T}
          />
          <SettingsScreen
            open={settingsOpen}
            onClose={() => setSettingsOpen(false)}
            T={T}
          />
          {focusTask && (
            <FocusScreen
              task={focusTask}
              onCancel={() => setFocusTask(null)}
              onFinish={handleFinish}
              T={T}
            />
          )}
        </div>
      </IOSDevice>

      <TweaksPanel>
        <TweakSection label="Theme" />
        <TweakRadio label="Palette" value={tw.palette}
          options={['sage','mist','clay']}
          onChange={(v) => setTweak('palette', v)} />
        <TweakSelect label="Font" value={tw.font}
          options={['Manrope','Inter Tight','Geist']}
          onChange={(v) => setTweak('font', v)} />
        <TweakSection label="Quick demo" />
        <TweakButton onClick={() => {
          // jump to focus mode for screenshots
          setFocusTask(tasks[0]);
        }}>Open Focus mode</TweakButton>
        <TweakButton onClick={() => { setAddOpen(true); }}>
          Open Add task
        </TweakButton>
        <TweakButton onClick={() => { setSettingsOpen(true); }}>
          Open Settings
        </TweakButton>
      </TweaksPanel>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
