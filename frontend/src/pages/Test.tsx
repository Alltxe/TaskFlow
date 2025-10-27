export function TestPage() {
  return (
    <div style={{ padding: '20px', backgroundColor: '#f0f0f0', minHeight: '100vh' }}>
      <h1 style={{ color: 'red' }}>TEST PAGE - If you see this, React is working!</h1>
      <p>This is a simple test page to verify React rendering.</p>
      <button onClick={() => alert('Button clicked!')}>Click me</button>
    </div>
  )
}
