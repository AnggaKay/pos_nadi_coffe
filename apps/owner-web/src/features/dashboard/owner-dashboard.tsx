import { dashboardDemo } from './demo-data';

const metrics = [
  { label: 'Omzet', value: dashboardDemo.revenue, change: '+12,8%' },
  { label: 'Transaksi', value: dashboardDemo.transactionCount, change: '+8,2%' },
  { label: 'Rata-rata transaksi', value: dashboardDemo.averageOrder, change: '+3,4%' },
  { label: 'Laba kotor tercatat', value: dashboardDemo.grossProfit, change: 'Demo HPP' },
];

export function OwnerDashboard() {
  return (
    <main className="min-h-screen lg:flex">
      <aside className="hidden w-60 shrink-0 flex-col border-r border-[var(--line)] bg-white p-5 lg:flex">
        <div className="mb-10 flex items-center gap-3">
          <div className="grid size-10 place-items-center rounded-xl bg-[var(--primary)] text-lg font-bold text-white">N</div>
          <div><p className="font-bold">Nadi Coffee</p><p className="text-xs text-[var(--muted)]">Owner workspace</p></div>
        </div>
        <p className="mb-3 px-3 text-[10px] font-bold tracking-[0.16em] text-[var(--muted)]">MONITORING</p>
        <nav className="space-y-1 text-sm">
          <a className="block rounded-xl bg-[var(--primary)] px-3 py-3 font-semibold text-white" href="#overview">Overview</a>
          <a className="block rounded-xl px-3 py-3 text-slate-600 hover:bg-slate-50" href="#sales">Penjualan</a>
          <a className="block rounded-xl px-3 py-3 text-slate-600 hover:bg-slate-50" href="#transactions">Transaksi</a>
          <a className="block rounded-xl px-3 py-3 text-slate-600 hover:bg-slate-50" href="#inventory">Inventaris</a>
        </nav>
        <div className="mt-auto rounded-xl border border-[var(--line)] bg-[var(--canvas)] p-3 text-xs text-[var(--muted)]">Outlet Pusat<br /><span className="mt-1 inline-block font-semibold text-[var(--ink)]">Satu outlet</span></div>
      </aside>

      <div className="min-w-0 flex-1">
        <header className="flex h-[68px] items-center justify-between border-b border-[var(--line)] bg-white px-5 lg:px-8">
          <div><p className="text-sm font-bold">Owner Overview</p><p className="text-[11px] text-[var(--muted)]">Nadi Coffee · Outlet Pusat</p></div>
          <button className="rounded-lg border border-[var(--line)] px-3 py-2 text-xs font-semibold">5 Okt 2026</button>
        </header>

        <div className="mx-auto max-w-[1440px] p-5 lg:p-8">
          <div className="mb-5 flex flex-wrap items-end justify-between gap-4">
            <div><p className="text-2xl font-extrabold tracking-tight lg:text-[28px]">Selamat pagi, Owner</p><p className="mt-1 text-sm text-[var(--muted)]">Pantau ringkasan operasional Nadi Coffee.</p></div>
            <div className="flex gap-1 rounded-xl border border-[var(--line)] bg-white p-1 text-xs">
              {['Hari ini', '7 hari', 'Bulan ini'].map((period, index) => <button key={period} className={`rounded-lg px-3 py-2 font-semibold ${index === 1 ? 'bg-[var(--primary)] text-white' : 'text-[var(--muted)]'}`}>{period}</button>)}
            </div>
          </div>

          <div className="mb-6 rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-xs font-medium text-amber-900">Prototype Owner · Angka yang tampil adalah data demo dan belum terhubung ke transaksi outlet.</div>

          <section id="overview" className="mb-6 grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">
            {metrics.map((metric) => <article key={metric.label} className="rounded-2xl border border-[var(--line)] bg-white p-5">
              <p className="text-xs font-medium text-[var(--muted)]">{metric.label}</p><p className="mt-3 text-xl font-extrabold tracking-tight">{metric.value}</p><p className="mt-2 text-[11px] font-semibold text-[var(--primary)]">{metric.change}</p>
            </article>)}
          </section>

          <div className="mb-6 grid gap-4 xl:grid-cols-12">
            <section id="sales" className="rounded-2xl border border-[var(--line)] bg-white p-5 xl:col-span-7">
              <div className="mb-6 flex items-start justify-between"><div><h2 className="text-sm font-extrabold">Tren penjualan</h2><p className="mt-1 text-xs text-[var(--muted)]">Omzet harian · {dashboardDemo.period}</p></div><button className="text-xs font-semibold text-[var(--primary)]">Lihat laporan</button></div>
              <p className="text-2xl font-extrabold">{dashboardDemo.revenue}</p><p className="mt-1 text-[11px] text-[var(--muted)]">Total periode demo</p>
              <div className="mt-6 flex h-40 items-end gap-3 sm:gap-5">{dashboardDemo.sales.map((item, index) => <div key={item.day} className="flex h-full flex-1 flex-col items-center justify-end gap-2"><div className={`w-full rounded-t-md ${index === 5 ? 'bg-[var(--primary)]' : 'bg-[#dce9df]'}`} style={{ height: `${item.amount / 4.2 * 100}%` }} /><span className="text-[10px] text-[var(--muted)]">{item.day}</span></div>)}</div>
            </section>

            <section id="inventory" className="rounded-2xl border border-[var(--line)] bg-white p-5 xl:col-span-5">
              <div className="mb-5"><h2 className="text-sm font-extrabold">Status stok</h2><p className="mt-1 text-xs text-[var(--muted)]">Perlu perhatian · data demo</p></div>
              <div className="space-y-4">{dashboardDemo.stockAlerts.map((item) => <div key={item.name} className="flex items-center justify-between gap-3"><div><p className="text-xs font-bold">{item.name}</p><p className="mt-1 text-[10px] text-[var(--muted)]">{item.detail}</p></div><span className={`rounded-full px-2 py-1 text-[9px] font-bold ${item.state === 'critical' ? 'bg-red-50 text-red-700' : item.state === 'warning' ? 'bg-amber-50 text-amber-700' : 'bg-emerald-50 text-emerald-700'}`}>{item.state === 'critical' ? 'Menipis' : item.state === 'warning' ? 'Periksa' : 'Aman'}</span></div>)}</div>
            </section>
          </div>

          <div className="grid gap-4 xl:grid-cols-12">
            <section id="transactions" className="rounded-2xl border border-[var(--line)] bg-white p-5 xl:col-span-7">
              <div className="mb-5 flex items-center justify-between"><div><h2 className="text-sm font-extrabold">Transaksi terbaru</h2><p className="mt-1 text-xs text-[var(--muted)]">Aktivitas kasir pada outlet</p></div><button className="text-xs font-semibold text-[var(--primary)]">Lihat semua</button></div>
              <div className="space-y-4">{dashboardDemo.transactions.map((transaction) => <div key={transaction.id} className="flex items-center justify-between border-b border-slate-100 pb-3 last:border-0 last:pb-0"><div><p className="text-xs font-bold">{transaction.id}</p><p className="mt-1 text-[10px] text-[var(--muted)]">{transaction.detail}</p></div><p className="text-xs font-bold">{transaction.amount}</p></div>)}</div>
            </section>

            <section className="rounded-2xl border border-[var(--line)] bg-white p-5 xl:col-span-5">
              <div className="mb-4"><h2 className="text-sm font-extrabold">Status sinkronisasi</h2><p className="mt-1 text-xs text-[var(--muted)]">Kesehatan data perangkat kasir</p></div>
              <span className="inline-flex rounded-full bg-amber-50 px-3 py-1.5 text-[10px] font-bold text-amber-800">Belum terhubung</span>
              <dl className="mt-5 space-y-3 text-[11px]"><div className="flex justify-between"><dt className="text-[var(--muted)]">Perangkat kasir</dt><dd className="font-semibold">Nadi POS · Tablet</dd></div><div className="flex justify-between"><dt className="text-[var(--muted)]">Sync terakhir</dt><dd className="font-semibold">Belum tersedia</dd></div><div className="flex justify-between"><dt className="text-[var(--muted)]">Antrean tertunda</dt><dd className="font-semibold">—</dd></div></dl>
              <p className="mt-4 text-[10px] leading-relaxed text-[var(--muted)]">Status ini adalah placeholder prototype. Integrasi sync direncanakan pada fase berikutnya.</p>
            </section>
          </div>
        </div>
      </div>
    </main>
  );
}
