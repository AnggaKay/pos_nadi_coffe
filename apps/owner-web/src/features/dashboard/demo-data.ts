export const dashboardDemo = {
  period: '7 hari terakhir',
  revenue: 'Rp 18.640.000',
  transactionCount: '542',
  averageOrder: 'Rp 34.391',
  grossProfit: 'Rp 9.240.000',
  sales: [
    { day: 'Sen', amount: 2.1 },
    { day: 'Sel', amount: 2.7 },
    { day: 'Rab', amount: 2.3 },
    { day: 'Kam', amount: 3.2 },
    { day: 'Jum', amount: 2.9 },
    { day: 'Sab', amount: 4.1 },
    { day: 'Min', amount: 3.3 },
  ],
  stockAlerts: [
    { name: 'Susu fresh milk', detail: 'Menipis · tersisa 2,4 L', state: 'critical' },
    { name: 'Cup 16 oz', detail: 'Di bawah batas minimum', state: 'warning' },
    { name: 'Biji kopi house blend', detail: 'Stok aman · 4,8 kg', state: 'healthy' },
  ],
  transactions: [
    { id: '#NC-0184', detail: 'QRIS · 10.42', amount: 'Rp 86.000' },
    { id: '#NC-0183', detail: 'Tunai · 10.35', amount: 'Rp 54.000' },
    { id: '#NC-0182', detail: 'QRIS · 10.28', amount: 'Rp 72.000' },
  ],
} as const;
