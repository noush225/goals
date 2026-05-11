// screens.jsx — Home, AddTask sheet, FocusMode overlay, Settings overlay
// All consume the `T` (theme) object from app.jsx via props.

const { useState, useEffect, useRef, useMemo } = React;

// ─────────────────────────────────────────────────────────────────────────────
// Shared primitives
// ─────────────────────────────────────────────────────────────────────────────

// A button that subtly scales on press (haptic-style micro-animation)
function PressButton({ children, onClick, style, ariaLabel, className = '' }) {
  const [pressed, setPressed] = useState(false);
  return (
    <button
      aria-label={ariaLabel}
      onClick={onClick}
      onPointerDown={() => setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      className={className}
      style={{
        appearance: 'none', border: 0, background: 'transparent', padding: 0,
        cursor: 'pointer', font: 'inherit', color: 'inherit',
        transform: pressed ? 'scale(0.94)' : 'scale(1)',
        transition: 'transform 120ms cubic-bezier(.3,.7,.4,1)',
        ...style,
      }}>
      {children}
    </button>
  );
}

function formatTime(totalMin) {
  const h = Math.floor(totalMin / 60);
  const m = totalMin % 60;
  if (h && m) return `${h}h ${m}m`;
  if (h) return `${h}h`;
  return `${m}m`;
}

function formatMMSS(totalSec) {
  const m = Math.floor(totalSec / 60).toString().padStart(2, '0');
  const s = (totalSec % 60).toString().padStart(2, '0');
  return `${m}:${s}`;
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME / DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

function SegmentedControl({ value, onChange, options, T }) {
  return (
    <div style={{
      display: 'inline-flex', position: 'relative',
      background: T.surfaceSunk, padding: 4, borderRadius: 999,
      width: '100%', boxSizing: 'border-box',
    }}>
      <div style={{
        position: 'absolute', top: 4, bottom: 4,
        left: value === options[0].value ? 4 : '50%',
        width: 'calc(50% - 4px)', borderRadius: 999,
        background: T.surface,
        boxShadow: '0 1px 2px rgba(45,58,46,0.06), 0 1px 6px rgba(45,58,46,0.04)',
        transition: 'left 280ms cubic-bezier(.3,.7,.4,1)',
      }} />
      {options.map(opt => (
        <button key={opt.value} onClick={() => onChange(opt.value)} style={{
          position: 'relative', flex: 1, border: 0, background: 'transparent',
          padding: '10px 0', fontSize: 14.5, fontWeight: 600,
          color: value === opt.value ? T.ink : T.muted,
          letterSpacing: '-0.01em', cursor: 'pointer',
          transition: 'color 200ms ease',
          fontFamily: 'inherit',
        }}>{opt.label}</button>
      ))}
    </div>
  );
}

function ProgressBar({ value, T, height = 4 }) {
  return (
    <div style={{
      height, background: T.hairline, borderRadius: 999, overflow: 'hidden',
      width: '100%',
    }}>
      <div style={{
        height: '100%', width: `${value}%`,
        background: T.accent,
        borderRadius: 999,
        transition: 'width 600ms cubic-bezier(.3,.7,.4,1)',
      }} />
    </div>
  );
}

function TaskCard({ task, onPlay, T }) {
  const isProg = task.type === 'progression';
  return (
    <div style={{
      background: T.surface, borderRadius: 22, padding: '18px 18px 18px 20px',
      display: 'flex', flexDirection: 'column', gap: 14,
      boxShadow: '0 1px 2px rgba(45,58,46,0.04), 0 8px 24px -12px rgba(45,58,46,0.08)',
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 8,
            fontSize: 11.5, fontWeight: 600, letterSpacing: '0.06em',
            textTransform: 'uppercase', color: T.muted, marginBottom: 6,
          }}>
            {isProg
              ? <ISteps size={13} style={{ color: T.accent }} />
              : <ITarget size={13} style={{ color: T.accent }} />}
            <span>{isProg ? 'Progression' : 'One-shot'}</span>
            <Dot color={T.muted} />
            <span style={{ color: T.muted, textTransform: 'none', letterSpacing: '-0.01em', fontWeight: 500 }}>
              {formatTime(task.minutes)}
            </span>
          </div>
          <div style={{
            fontSize: 19, fontWeight: 600, color: T.ink,
            letterSpacing: '-0.02em', lineHeight: 1.25,
            textWrap: 'pretty',
          }}>{task.title}</div>
        </div>
        <PressButton onClick={() => onPlay(task)} ariaLabel={`Start ${task.title}`} style={{
          width: 48, height: 48, borderRadius: 999,
          background: T.accent, color: T.surface,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          flexShrink: 0,
          boxShadow: `0 6px 18px -6px ${T.accentShadow}`,
        }}>
          <IPlay size={18} style={{ marginLeft: 2 }} />
        </PressButton>
      </div>
      {isProg && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <ProgressBar value={task.progress} T={T} />
          <div style={{
            display: 'flex', justifyContent: 'space-between',
            fontSize: 12, color: T.muted, fontVariantNumeric: 'tabular-nums',
            letterSpacing: '-0.01em',
          }}>
            <span>{task.progress}% complete</span>
            <span>{task.subtasks || ''}</span>
          </div>
        </div>
      )}
    </div>
  );
}

function HomeScreen({ tasks, tab, onTab, onAdd, onPlay, onSettings, T }) {
  const today = new Date(2026, 4, 11); // May 11 2026 — Monday
  const dateLabel = today.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });

  const doneCount = tasks.filter(t => t.progress === 100).length;
  const totalMin = tasks.reduce((s, t) => s + t.minutes, 0);

  return (
    <div style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      background: T.bg, position: 'relative',
    }}>
      {/* Header */}
      <div style={{
        padding: '54px 24px 0', display: 'flex',
        alignItems: 'center', justifyContent: 'space-between',
      }}>
        <div style={{
          fontSize: 22, fontWeight: 700, color: T.ink,
          letterSpacing: '-0.025em',
          display: 'flex', alignItems: 'center', gap: 8,
        }}>
          <span style={{
            width: 22, height: 22, borderRadius: 6, background: T.accent,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <span style={{
              width: 6, height: 6, borderRadius: '50%',
              background: T.surface,
              boxShadow: `0 0 0 4px ${T.accent}, 0 0 0 5px rgba(255,255,255,0.4)`,
            }} />
          </span>
          Momentum
        </div>
        <PressButton onClick={onSettings} ariaLabel="Settings" style={{
          width: 40, height: 40, borderRadius: 999,
          background: T.surface, color: T.inkSoft,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 1px 2px rgba(45,58,46,0.04)',
        }}>
          <IGear size={19} />
        </PressButton>
      </div>

      {/* Greeting + stat row */}
      <div style={{ padding: '24px 24px 8px' }}>
        <div style={{
          fontSize: 13, fontWeight: 500, color: T.muted,
          letterSpacing: '-0.005em', marginBottom: 6,
        }}>{dateLabel}</div>
        <div style={{
          fontSize: 28, fontWeight: 700, color: T.ink,
          letterSpacing: '-0.03em', lineHeight: 1.15,
          textWrap: 'balance',
        }}>
          Make today<br/>count.
        </div>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 0,
          marginTop: 14, fontSize: 13, color: T.inkSoft,
          letterSpacing: '-0.01em',
        }}>
          <span style={{ fontWeight: 600, color: T.ink }}>{doneCount} of {tasks.length}</span>
          <span style={{ marginLeft: 4 }}>done</span>
          <Dot color={T.muted} />
          <span style={{ fontWeight: 600, color: T.ink }}>{formatTime(totalMin)}</span>
          <span style={{ marginLeft: 4 }}>focused</span>
        </div>
      </div>

      {/* Tabs */}
      <div style={{ padding: '18px 24px 14px' }}>
        <SegmentedControl
          value={tab} onChange={onTab} T={T}
          options={[{ value: 'today', label: 'Today' }, { value: 'week', label: 'This Week' }]}
        />
      </div>

      {/* Task list */}
      <div style={{
        flex: 1, overflowY: 'auto', overflowX: 'hidden',
        padding: '6px 24px 140px',
        display: 'flex', flexDirection: 'column', gap: 14,
        scrollbarWidth: 'none',
      }}>
        {tasks.map(task => (
          <TaskCard key={task.id} task={task} onPlay={onPlay} T={T} />
        ))}
      </div>

      {/* FAB */}
      <PressButton onClick={onAdd} ariaLabel="Add task" style={{
        position: 'absolute', right: 22, bottom: 44,
        width: 60, height: 60, borderRadius: 999,
        background: T.ink, color: T.surface,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: `0 12px 28px -8px ${T.inkShadow}, 0 2px 6px rgba(45,58,46,0.12)`,
        zIndex: 30,
      }}>
        <IPlus size={26} />
      </PressButton>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD TASK MODAL (bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

function MiniCalendar({ selected, onSelect, T }) {
  // Centered on May 2026. Days laid out as 7-col grid.
  const month = 4, year = 2026; // May 2026
  const firstDay = new Date(year, month, 1);
  const startDow = (firstDay.getDay() + 6) % 7; // Monday-first
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const cells = [];
  for (let i = 0; i < startDow; i++) cells.push(null);
  for (let d = 1; d <= daysInMonth; d++) cells.push(d);
  while (cells.length % 7) cells.push(null);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      <div style={{
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        padding: '0 4px',
      }}>
        <div style={{ fontSize: 14, fontWeight: 600, color: T.ink, letterSpacing: '-0.01em' }}>
          May 2026
        </div>
        <div style={{ display: 'flex', gap: 4, color: T.inkSoft }}>
          <PressButton ariaLabel="Previous month" style={{
            width: 28, height: 28, borderRadius: 8,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><IChevronLeft size={16} /></PressButton>
          <PressButton ariaLabel="Next month" style={{
            width: 28, height: 28, borderRadius: 8,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><IChevronRight size={16} /></PressButton>
        </div>
      </div>
      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', gap: 2,
        fontSize: 11, color: T.muted, letterSpacing: '0.04em',
        textTransform: 'uppercase', fontWeight: 600, textAlign: 'center',
      }}>
        {['M','T','W','T','F','S','S'].map((d, i) => <div key={i}>{d}</div>)}
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', gap: 2 }}>
        {cells.map((d, i) => {
          if (!d) return <div key={i} />;
          const isSel = d === selected;
          const isToday = d === 11;
          return (
            <button key={i} onClick={() => onSelect(d)} style={{
              aspectRatio: '1', border: 0,
              background: isSel ? T.ink : 'transparent',
              color: isSel ? T.surface : (isToday ? T.accent : T.ink),
              borderRadius: 10, fontSize: 14, fontWeight: isToday || isSel ? 600 : 500,
              fontFamily: 'inherit', cursor: 'pointer',
              fontVariantNumeric: 'tabular-nums',
              transition: 'background 160ms ease',
            }}>{d}</button>
          );
        })}
      </div>
    </div>
  );
}

function AddTaskSheet({ open, onClose, onSave, tasks, T }) {
  const [title, setTitle] = useState('');
  const [type, setType] = useState('oneshot');
  const [progress, setProgress] = useState(20);
  const [date, setDate] = useState(11);
  const [parent, setParent] = useState('');
  const [parentOpen, setParentOpen] = useState(false);
  const inputRef = useRef(null);

  useEffect(() => {
    if (open) {
      setTitle(''); setType('oneshot'); setProgress(20); setDate(11); setParent(''); setParentOpen(false);
      setTimeout(() => inputRef.current?.focus(), 320);
    }
  }, [open]);

  const canSave = title.trim().length > 0;

  return (
    <>
      {/* backdrop */}
      <div onClick={onClose} style={{
        position: 'absolute', inset: 0, zIndex: 40,
        background: 'rgba(20,24,22,0.32)',
        opacity: open ? 1 : 0,
        pointerEvents: open ? 'auto' : 'none',
        transition: 'opacity 300ms ease',
        backdropFilter: 'blur(2px)',
      }} />
      {/* sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 41,
        background: T.bg,
        borderRadius: '28px 28px 0 0',
        transform: open ? 'translateY(0)' : 'translateY(100%)',
        transition: 'transform 380ms cubic-bezier(.3,.7,.4,1)',
        boxShadow: '0 -8px 32px rgba(45,58,46,0.18)',
        display: 'flex', flexDirection: 'column',
        maxHeight: '88%',
      }}>
        {/* drag handle */}
        <div style={{ display: 'flex', justifyContent: 'center', padding: '10px 0 4px' }}>
          <div style={{ width: 36, height: 4, background: T.hairline, borderRadius: 2 }} />
        </div>

        {/* header */}
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '12px 20px 8px',
        }}>
          <PressButton onClick={onClose} style={{
            fontSize: 15, color: T.inkSoft, fontWeight: 500,
            padding: '6px 4px', letterSpacing: '-0.01em',
          }}>Cancel</PressButton>
          <div style={{ fontSize: 15, fontWeight: 600, color: T.ink, letterSpacing: '-0.01em' }}>
            New Task
          </div>
          <div style={{ width: 56 }} />
        </div>

        {/* body */}
        <div style={{
          flex: 1, overflowY: 'auto', padding: '14px 24px 24px',
          display: 'flex', flexDirection: 'column', gap: 22,
          scrollbarWidth: 'none',
        }}>
          {/* title */}
          <div>
            <input
              ref={inputRef}
              value={title}
              onChange={e => setTitle(e.target.value)}
              placeholder="What do you want to create?"
              style={{
                width: '100%', border: 0, background: 'transparent',
                fontFamily: 'inherit',
                fontSize: 26, fontWeight: 600, color: T.ink,
                letterSpacing: '-0.025em', padding: '8px 0',
                outline: 'none', textWrap: 'pretty',
              }}
            />
            <div style={{ height: 1, background: T.hairline }} />
          </div>

          {/* date */}
          <FieldGroup label="Date" T={T}>
            <MiniCalendar selected={date} onSelect={setDate} T={T} />
          </FieldGroup>

          {/* type */}
          <FieldGroup label="Task Type" T={T}>
            <div style={{
              display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8,
            }}>
              {[
                { val: 'oneshot', label: 'One-shot', icon: <ITarget size={16} />, sub: 'Single session' },
                { val: 'progression', label: 'Progression', icon: <ISteps size={16} />, sub: 'Track over time' },
              ].map(opt => {
                const sel = type === opt.val;
                return (
                  <PressButton key={opt.val} onClick={() => setType(opt.val)} style={{
                    padding: '14px 14px', borderRadius: 16,
                    background: sel ? T.ink : T.surface,
                    color: sel ? T.surface : T.ink,
                    display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 8,
                    transition: 'background 200ms ease, color 200ms ease',
                    border: sel ? 'none' : `1px solid ${T.hairline}`,
                    textAlign: 'left',
                  }}>
                    <div style={{
                      color: sel ? T.accentLight : T.accent,
                    }}>{opt.icon}</div>
                    <div>
                      <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: '-0.01em' }}>{opt.label}</div>
                      <div style={{ fontSize: 11.5, opacity: 0.6, marginTop: 2 }}>{opt.sub}</div>
                    </div>
                  </PressButton>
                );
              })}
            </div>
          </FieldGroup>

          {/* conditional progress slider */}
          {type === 'progression' && (
            <FieldGroup label="Starting Progress" T={T} value={`${progress}%`}>
              <div style={{ padding: '8px 4px 0' }}>
                <input type="range" min={0} max={100} value={progress}
                  onChange={e => setProgress(+e.target.value)}
                  style={{
                    width: '100%', accentColor: T.accent, height: 4,
                  }} />
              </div>
            </FieldGroup>
          )}

          {/* parent task */}
          <FieldGroup label="Parent Task" T={T} optional>
            <PressButton onClick={() => setParentOpen(o => !o)} style={{
              background: T.surface, padding: '14px 16px',
              border: `1px solid ${T.hairline}`,
              borderRadius: 14, width: '100%', textAlign: 'left',
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            }}>
              <span style={{
                fontSize: 15, fontWeight: 500,
                color: parent ? T.ink : T.muted, letterSpacing: '-0.01em',
              }}>{parent || 'None'}</span>
              <IChevronDown size={16} style={{ color: T.muted,
                transform: parentOpen ? 'rotate(180deg)' : 'none',
                transition: 'transform 200ms ease',
              }} />
            </PressButton>
            {parentOpen && (
              <div style={{
                marginTop: 6, background: T.surface, borderRadius: 14,
                border: `1px solid ${T.hairline}`, overflow: 'hidden',
              }}>
                {['None', ...tasks.map(t => t.title)].map((label, i, arr) => (
                  <button key={label} onClick={() => { setParent(label === 'None' ? '' : label); setParentOpen(false); }}
                    style={{
                      width: '100%', textAlign: 'left', border: 0, background: 'transparent',
                      padding: '13px 16px', fontFamily: 'inherit', fontSize: 14.5,
                      color: T.ink, cursor: 'pointer', letterSpacing: '-0.01em',
                      borderBottom: i < arr.length - 1 ? `1px solid ${T.hairline}` : 'none',
                    }}>{label}</button>
                ))}
              </div>
            )}
          </FieldGroup>
        </div>

        {/* footer */}
        <div style={{
          padding: '14px 24px 34px',
          borderTop: `1px solid ${T.hairline}`,
          background: T.bg,
        }}>
          <PressButton
            onClick={() => canSave && onSave({ title, type, progress: type === 'progression' ? progress : 100, parent })}
            style={{
              width: '100%', padding: '17px 0', borderRadius: 16,
              background: canSave ? T.ink : T.hairline,
              color: canSave ? T.surface : T.muted,
              fontSize: 16, fontWeight: 600, letterSpacing: '-0.01em',
              transition: 'background 200ms ease',
            }}>
            Save Task
          </PressButton>
        </div>
      </div>
    </>
  );
}

function FieldGroup({ label, value, optional, children, T }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      <div style={{
        display: 'flex', justifyContent: 'space-between', alignItems: 'baseline',
        fontSize: 11.5, fontWeight: 600, letterSpacing: '0.06em',
        textTransform: 'uppercase', color: T.muted,
      }}>
        <span>{label}{optional && <span style={{ fontWeight: 500, opacity: 0.7 }}> · optional</span>}</span>
        {value && <span style={{
          textTransform: 'none', letterSpacing: '-0.01em', color: T.ink,
          fontWeight: 600, fontSize: 13,
        }}>{value}</span>}
      </div>
      {children}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FOCUS MODE (dark immersive)
// ─────────────────────────────────────────────────────────────────────────────

function FocusScreen({ task, onCancel, onFinish, T }) {
  const [sec, setSec] = useState(0);
  const [musicPlaying, setMusicPlaying] = useState(true);
  const [muted, setMuted] = useState(false);

  useEffect(() => {
    setSec(0);
    const id = setInterval(() => setSec(s => s + 1), 1000);
    return () => clearInterval(id);
  }, [task?.id]);

  if (!task) return null;
  const focus = T.focus;

  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 50,
      background: focus.bg,
      color: focus.ink,
      display: 'flex', flexDirection: 'column',
      animation: 'focusFade 400ms ease',
    }}>
      {/* ambient glow */}
      <div style={{
        position: 'absolute', top: '38%', left: '50%',
        transform: 'translate(-50%,-50%)',
        width: 460, height: 460, borderRadius: '50%',
        background: `radial-gradient(circle, ${focus.glow} 0%, transparent 65%)`,
        pointerEvents: 'none',
        animation: 'breathe 6s ease-in-out infinite',
      }} />

      {/* top bar */}
      <div style={{
        padding: '54px 24px 0', display: 'flex',
        alignItems: 'center', justifyContent: 'space-between',
        position: 'relative', zIndex: 2,
      }}>
        <PressButton onClick={onCancel} ariaLabel="Cancel session" style={{
          width: 40, height: 40, borderRadius: 999,
          background: 'rgba(255,255,255,0.06)',
          color: focus.inkSoft,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          backdropFilter: 'blur(8px)',
        }}>
          <IX size={18} />
        </PressButton>
        <div style={{
          fontSize: 11.5, fontWeight: 600, letterSpacing: '0.14em',
          textTransform: 'uppercase', color: focus.muted,
        }}>Focus Session</div>
        <div style={{ width: 40 }} />
      </div>

      {/* center */}
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        padding: '0 32px', position: 'relative', zIndex: 2,
        gap: 16, marginTop: -40,
      }}>
        <div style={{
          fontSize: 14, fontWeight: 500, color: focus.muted,
          letterSpacing: '0.04em', textTransform: 'uppercase',
        }}>Working on</div>
        <div style={{
          fontSize: 21, fontWeight: 500, color: focus.ink,
          letterSpacing: '-0.01em', textAlign: 'center', textWrap: 'balance',
          maxWidth: 280, lineHeight: 1.3,
        }}>{task.title}</div>

        <div style={{ height: 24 }} />

        {/* breathing ring around timer */}
        <div style={{ position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{
            position: 'absolute', width: 280, height: 280, borderRadius: '50%',
            border: `1px solid ${focus.ring}`,
            animation: 'breathe 6s ease-in-out infinite',
          }} />
          <div style={{
            position: 'absolute', width: 320, height: 320, borderRadius: '50%',
            border: `1px solid ${focus.ringFaint}`,
            animation: 'breathe 6s ease-in-out infinite 0.5s',
          }} />
          <div style={{
            fontSize: 76, fontWeight: 300, color: focus.timer,
            letterSpacing: '-0.04em', fontVariantNumeric: 'tabular-nums',
            textShadow: `0 0 32px ${focus.timerGlow}`,
            fontFeatureSettings: '"tnum"',
          }}>
            {formatMMSS(sec)}
          </div>
        </div>

        <div style={{ height: 24 }} />

        {/* music widget */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 14,
          padding: '10px 14px 10px 16px',
          background: 'rgba(255,255,255,0.05)',
          border: `1px solid ${focus.ring}`,
          borderRadius: 999,
          backdropFilter: 'blur(10px)',
        }}>
          <IMusic size={15} style={{ color: focus.accent }} />
          <div style={{ fontSize: 13, color: focus.ink, letterSpacing: '-0.01em' }}>
            Forest Rain
          </div>
          <Waveform playing={musicPlaying} color={focus.accent} />
          <PressButton onClick={() => setMusicPlaying(p => !p)} ariaLabel="Play/Pause music" style={{
            width: 30, height: 30, borderRadius: 999,
            background: 'rgba(255,255,255,0.08)', color: focus.ink,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            {musicPlaying ? <IPause size={13} /> : <IPlay size={13} />}
          </PressButton>
          <PressButton onClick={() => setMuted(m => !m)} ariaLabel="Mute" style={{
            width: 30, height: 30, borderRadius: 999,
            color: muted ? focus.muted : focus.ink,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            {muted ? <IMute size={14} /> : <ISpeaker size={14} />}
          </PressButton>
        </div>
      </div>

      {/* finish button */}
      <div style={{ padding: '0 24px 56px', position: 'relative', zIndex: 2 }}>
        <PressButton onClick={() => onFinish(sec)} style={{
          width: '100%', padding: '20px 0', borderRadius: 20,
          background: focus.accent, color: focus.bg,
          fontSize: 17, fontWeight: 600, letterSpacing: '-0.01em',
          boxShadow: `0 0 40px ${focus.timerGlow}`,
        }}>
          Finish Session
        </PressButton>
      </div>

      <style>{`
        @keyframes breathe {
          0%, 100% { transform: translate(-50%,-50%) scale(1); opacity: 0.9; }
          50% { transform: translate(-50%,-50%) scale(1.08); opacity: 1; }
        }
        @keyframes focusFade {
          from { opacity: 0; }
          to { opacity: 1; }
        }
      `}</style>
    </div>
  );
}

function Waveform({ playing, color }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 2, height: 14 }}>
      {[0, 1, 2, 3, 4].map(i => (
        <div key={i} style={{
          width: 2, background: color, borderRadius: 1,
          height: playing ? undefined : 3,
          animation: playing ? `wf 0.9s ease-in-out infinite ${i * 0.12}s` : 'none',
          opacity: playing ? 1 : 0.4,
        }} />
      ))}
      <style>{`
        @keyframes wf {
          0%, 100% { height: 4px; }
          50% { height: 12px; }
        }
      `}</style>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS (slide-in from right)
// ─────────────────────────────────────────────────────────────────────────────

function SettingsScreen({ open, onClose, T }) {
  const [reminderOn, setReminderOn] = useState(true);
  const [reminderTime, setReminderTime] = useState({ h: 9, m: 0, ampm: 'AM' });
  const [pickerOpen, setPickerOpen] = useState(false);
  const [lang, setLang] = useState('Français');
  const [langOpen, setLangOpen] = useState(false);

  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 45,
      background: T.bg,
      transform: open ? 'translateX(0)' : 'translateX(100%)',
      transition: 'transform 360ms cubic-bezier(.3,.7,.4,1)',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* header */}
      <div style={{
        padding: '54px 20px 0', display: 'flex',
        alignItems: 'center', gap: 4,
      }}>
        <PressButton onClick={onClose} ariaLabel="Back" style={{
          width: 40, height: 40, borderRadius: 999,
          background: T.surface, color: T.inkSoft,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 1px 2px rgba(45,58,46,0.04)',
        }}>
          <IChevronLeft size={18} />
        </PressButton>
      </div>

      <div style={{ padding: '20px 24px 8px' }}>
        <div style={{
          fontSize: 32, fontWeight: 700, color: T.ink,
          letterSpacing: '-0.03em',
        }}>Settings</div>
      </div>

      <div style={{
        flex: 1, overflowY: 'auto', padding: '14px 24px 40px',
        display: 'flex', flexDirection: 'column', gap: 28,
        scrollbarWidth: 'none',
      }}>
        {/* Notifications */}
        <SettingsSection title="Notifications" T={T}>
          <SettingsRow T={T} icon={<IBell size={17} />} label="Daily Reminder"
            sub="Gentle nudge to start your day"
            control={<Toggle on={reminderOn} onChange={setReminderOn} T={T} />} />
          <SettingsRow T={T} icon={<ICalendar size={17} />} label="Reminder Time"
            sub={reminderOn ? "When we'll check in" : "Enable reminders to set"}
            disabled={!reminderOn}
            control={
              <PressButton onClick={() => reminderOn && setPickerOpen(o => !o)} style={{
                fontSize: 17, fontWeight: 600, color: reminderOn ? T.accent : T.muted,
                fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.01em',
              }}>
                {String(reminderTime.h).padStart(2,'0')}:{String(reminderTime.m).padStart(2,'0')} {reminderTime.ampm}
              </PressButton>
            } />
          {pickerOpen && reminderOn && (
            <TimePicker value={reminderTime} onChange={setReminderTime} T={T} />
          )}
        </SettingsSection>

        {/* Language */}
        <SettingsSection title="Language" T={T}>
          <SettingsRow T={T} icon={<IGlobe size={17} />} label="App Language"
            sub="Changes apply immediately"
            control={
              <PressButton onClick={() => setLangOpen(o => !o)} style={{
                display: 'flex', alignItems: 'center', gap: 4,
                fontSize: 15, fontWeight: 500, color: T.ink,
                letterSpacing: '-0.01em',
              }}>
                <span>{lang}</span>
                <IChevronDown size={15} style={{ color: T.muted,
                  transform: langOpen ? 'rotate(180deg)' : 'none',
                  transition: 'transform 200ms ease',
                }} />
              </PressButton>
            } />
          {langOpen && (
            <div style={{
              background: T.surface, borderRadius: 14, overflow: 'hidden',
              border: `1px solid ${T.hairline}`,
            }}>
              {['Français','English','Español','Deutsch','日本語'].map((l, i, arr) => (
                <button key={l} onClick={() => { setLang(l); setLangOpen(false); }}
                  style={{
                    width: '100%', textAlign: 'left', border: 0, background: 'transparent',
                    padding: '14px 16px', fontFamily: 'inherit', fontSize: 15,
                    color: T.ink, cursor: 'pointer', letterSpacing: '-0.01em',
                    borderBottom: i < arr.length - 1 ? `1px solid ${T.hairline}` : 'none',
                    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  }}>
                  <span>{l}</span>
                  {l === lang && <ICheck size={16} style={{ color: T.accent }} />}
                </button>
              ))}
            </div>
          )}
        </SettingsSection>

        {/* tiny footer */}
        <div style={{
          marginTop: 'auto', paddingTop: 30,
          fontSize: 11.5, color: T.muted, textAlign: 'center',
          letterSpacing: '0.04em',
        }}>
          Momentum · v1.0
        </div>
      </div>
    </div>
  );
}

function SettingsSection({ title, children, T }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      <div style={{
        fontSize: 11.5, fontWeight: 600, letterSpacing: '0.08em',
        textTransform: 'uppercase', color: T.muted, padding: '0 4px',
      }}>{title}</div>
      <div style={{
        background: T.surface, borderRadius: 18, overflow: 'hidden',
        display: 'flex', flexDirection: 'column',
      }}>
        {children}
      </div>
    </div>
  );
}

function SettingsRow({ icon, label, sub, control, disabled, T }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 14,
      padding: '16px 18px', minHeight: 60,
      opacity: disabled ? 0.5 : 1,
      transition: 'opacity 200ms ease',
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 10,
        background: T.surfaceSunk, color: T.accent,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontSize: 15, fontWeight: 500, color: T.ink,
          letterSpacing: '-0.01em', lineHeight: 1.2,
        }}>{label}</div>
        {sub && <div style={{
          fontSize: 12.5, color: T.muted, marginTop: 2, letterSpacing: '-0.005em',
        }}>{sub}</div>}
      </div>
      <div style={{ flexShrink: 0 }}>{control}</div>
    </div>
  );
}

function Toggle({ on, onChange, T }) {
  return (
    <button onClick={() => onChange(!on)} style={{
      width: 50, height: 30, borderRadius: 999, border: 0, padding: 2,
      background: on ? T.accent : T.hairline,
      display: 'flex', alignItems: 'center',
      transition: 'background 240ms ease', cursor: 'pointer',
    }}>
      <div style={{
        width: 26, height: 26, borderRadius: '50%', background: T.surface,
        transform: on ? 'translateX(20px)' : 'translateX(0)',
        transition: 'transform 240ms cubic-bezier(.3,.7,.4,1)',
        boxShadow: '0 1px 3px rgba(0,0,0,0.15)',
      }} />
    </button>
  );
}

function TimePicker({ value, onChange, T }) {
  return (
    <div style={{
      background: T.surfaceSunk, padding: '14px 18px', borderRadius: 14,
      margin: '0 14px 14px', display: 'flex',
      alignItems: 'center', justifyContent: 'center', gap: 6,
    }}>
      <Stepper val={String(value.h).padStart(2,'0')}
        onUp={() => onChange({ ...value, h: value.h === 12 ? 1 : value.h + 1 })}
        onDown={() => onChange({ ...value, h: value.h === 1 ? 12 : value.h - 1 })}
        T={T} />
      <div style={{ fontSize: 26, color: T.ink, fontWeight: 500 }}>:</div>
      <Stepper val={String(value.m).padStart(2,'0')}
        onUp={() => onChange({ ...value, m: (value.m + 5) % 60 })}
        onDown={() => onChange({ ...value, m: (value.m + 55) % 60 })}
        T={T} />
      <div style={{ width: 8 }} />
      <div style={{
        display: 'flex', flexDirection: 'column',
        background: T.surface, borderRadius: 10, padding: 3,
      }}>
        {['AM','PM'].map(p => (
          <button key={p} onClick={() => onChange({ ...value, ampm: p })} style={{
            border: 0, padding: '4px 10px', borderRadius: 8,
            background: value.ampm === p ? T.ink : 'transparent',
            color: value.ampm === p ? T.surface : T.muted,
            fontFamily: 'inherit', fontSize: 11, fontWeight: 600,
            letterSpacing: '0.04em', cursor: 'pointer',
          }}>{p}</button>
        ))}
      </div>
    </div>
  );
}

function Stepper({ val, onUp, onDown, T }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2 }}>
      <PressButton onClick={onUp} style={{
        width: 28, height: 22, color: T.muted,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}><IChevronDown size={14} style={{ transform: 'rotate(180deg)' }} /></PressButton>
      <div style={{
        fontSize: 26, fontWeight: 500, color: T.ink,
        fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.02em',
        minWidth: 36, textAlign: 'center',
      }}>{val}</div>
      <PressButton onClick={onDown} style={{
        width: 28, height: 22, color: T.muted,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}><IChevronDown size={14} /></PressButton>
    </div>
  );
}

Object.assign(window, {
  HomeScreen, AddTaskSheet, FocusScreen, SettingsScreen,
  PressButton, formatMMSS, formatTime,
});
