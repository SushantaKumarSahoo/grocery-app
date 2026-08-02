import { useAuth } from '../context/AuthContext';
import { Navigate, Link } from 'react-router-dom';
import {
  ShoppingCart, Truck, FileText, Star, ArrowRight,
  CheckCircle, UtensilsCrossed, Church, PartyPopper,
  Hotel, ChefHat, Briefcase, Shield, Zap, TrendingUp
} from 'lucide-react';

const occasions = [
  { name: 'Weddings', icon: <PartyPopper size={24} />, color: 'from-pink-500 to-rose-500' },
  { name: 'Catering', icon: <ChefHat size={24} />, color: 'from-orange-500 to-amber-500' },
  { name: 'Temples', icon: <Church size={24} />, color: 'from-yellow-500 to-orange-500' },
  { name: 'Hotels', icon: <Hotel size={24} />, color: 'from-blue-500 to-indigo-500' },
  { name: 'Restaurants', icon: <UtensilsCrossed size={24} />, color: 'from-green-500 to-emerald-500' },
  { name: 'Corporate', icon: <Briefcase size={24} />, color: 'from-purple-500 to-violet-500' },
];

const features = [
  {
    icon: <ShoppingCart size={28} />,
    title: 'Bulk Order Management',
    desc: 'Place large grocery orders for any occasion. Specify quantities, packaging, and delivery requirements with ease.',
  },
  {
    icon: <FileText size={28} />,
    title: 'Quotation-Based Pricing',
    desc: 'Receive detailed quotations from verified shop owners. Compare prices, negotiate, and accept the best deal.',
  },
  {
    icon: <Truck size={28} />,
    title: 'Reliable Delivery',
    desc: 'Schedule deliveries for your event date. Track orders in real-time and coordinate with suppliers directly.',
  },
  {
    icon: <Shield size={28} />,
    title: 'Verified Suppliers',
    desc: 'Every shop on our platform is verified. Quality assurance and transparent pricing you can trust.',
  },
  {
    icon: <Zap size={28} />,
    title: 'Instant Quotations',
    desc: 'Get quotations within hours, not days. Our streamlined process ensures you never have to wait.',
  },
  {
    icon: <TrendingUp size={28} />,
    title: 'Cost Savings',
    desc: 'Bulk pricing means significant savings. Save up to 30% compared to retail grocery purchases.',
  },
];

const steps = [
  { step: '01', title: 'Place Your Order', desc: 'Select your occasion, add products with quantities, and submit your bulk order request.' },
  { step: '02', title: 'Receive Quotation', desc: 'Shop owners review your request and send detailed quotations with pricing and availability.' },
  { step: '03', title: 'Accept & Pay', desc: 'Compare quotations, accept the best one, and make a secure payment to confirm your order.' },
  { step: '04', title: 'Get It Delivered', desc: 'Your bulk order is prepared and delivered right to your venue on time, every time.' },
];

const stats = [
  { value: '10,000+', label: 'Orders Fulfilled' },
  { value: '500+', label: 'Verified Suppliers' },
  { value: '50+', label: 'Cities Covered' },
  { value: '₹25Cr+', label: 'GMV Processed' },
];

export default function LandingPage() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="h-screen w-screen flex items-center justify-center bg-bg-main">
        <div className="flex flex-col items-center gap-4">
          <div className="w-10 h-10 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
          <p className="text-text-muted text-sm">Loading...</p>
        </div>
      </div>
    );
  }

  if (user) {
    return <Navigate to="/admin" replace />;
  }

  return (
    <div className="min-h-screen bg-bg-main">
      {/* Navbar */}
      <nav className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-lg border-b border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-2">
              <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-primary to-emerald-600 flex items-center justify-center text-white font-bold text-lg shadow-md">
                B
              </div>
              <span className="font-bold text-xl text-text-main">BulkBasket</span>
            </div>
            <div className="hidden md:flex items-center gap-8">
              <a href="#features" className="text-sm font-medium text-text-muted hover:text-text-main transition-colors">Features</a>
              <a href="#how-it-works" className="text-sm font-medium text-text-muted hover:text-text-main transition-colors">How It Works</a>
              <a href="#occasions" className="text-sm font-medium text-text-muted hover:text-text-main transition-colors">Occasions</a>
            </div>
            <div className="flex items-center gap-3">
              <Link to="/login" className="btn btn-ghost text-sm">Sign In</Link>
              <Link to="/login" className="btn btn-primary text-sm shadow-md shadow-primary/20">
                Get Started <ArrowRight size={16} />
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative pt-32 pb-20 overflow-hidden">
        {/* Background decoration */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute -top-40 -right-40 w-[500px] h-[500px] bg-primary/5 rounded-full blur-3xl"></div>
          <div className="absolute -bottom-40 -left-40 w-[500px] h-[500px] bg-secondary/5 rounded-full blur-3xl"></div>
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-accent/5 rounded-full blur-3xl"></div>
        </div>

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-4xl mx-auto">
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-primary-light text-primary text-sm font-semibold mb-6 border border-primary/10">
              <Star size={14} className="fill-primary" />
              India's #1 Bulk Grocery Ordering Platform
            </div>

            <h1 className="text-5xl sm:text-6xl lg:text-7xl font-bold text-text-main leading-tight tracking-tight">
              Bulk Groceries for
              <span className="bg-gradient-to-r from-primary to-emerald-600 bg-clip-text text-transparent"> Every Occasion</span>
            </h1>

            <p className="mt-6 text-lg sm:text-xl text-text-muted max-w-2xl mx-auto leading-relaxed">
              From weddings to corporate events — order groceries in bulk, receive competitive quotations from verified suppliers, and get everything delivered on time.
            </p>

            <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
              <Link to="/login" className="btn btn-primary text-base px-8 py-3.5 shadow-lg shadow-primary/25 hover:shadow-xl hover:shadow-primary/30 transition-all">
                Start Ordering Today <ArrowRight size={18} />
              </Link>
              <a href="#how-it-works" className="btn btn-outline text-base px-8 py-3.5">
                See How It Works
              </a>
            </div>

            <div className="mt-14 flex items-center justify-center gap-6 text-sm text-text-muted">
              <div className="flex items-center gap-2">
                <CheckCircle size={16} className="text-primary" />
                No minimum order
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle size={16} className="text-primary" />
                Verified suppliers
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle size={16} className="text-primary" />
                Free quotations
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 border-y border-border bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {stats.map((s, i) => (
              <div key={i} className="text-center">
                <p className="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">{s.value}</p>
                <p className="mt-2 text-sm text-text-muted font-medium">{s.label}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Occasions Section */}
      <section id="occasions" className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <h2 className="text-3xl sm:text-4xl font-bold text-text-main">Built for Every Occasion</h2>
            <p className="mt-4 text-text-muted text-lg max-w-2xl mx-auto">
              Whether it's a grand wedding or a daily hostel supply, we've got you covered.
            </p>
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
            {occasions.map((o, i) => (
              <div key={i} className="group cursor-pointer">
                <div className="card flex flex-col items-center gap-3 py-8 text-center hover:scale-[1.03] hover:shadow-lg transition-all duration-300 border-transparent hover:border-primary/20">
                  <div className={`w-14 h-14 rounded-xl bg-gradient-to-br ${o.color} flex items-center justify-center text-white shadow-lg group-hover:scale-110 transition-transform duration-300`}>
                    {o.icon}
                  </div>
                  <span className="font-semibold text-sm text-text-main">{o.name}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-white border-y border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <h2 className="text-3xl sm:text-4xl font-bold text-text-main">Everything You Need for Bulk Procurement</h2>
            <p className="mt-4 text-text-muted text-lg max-w-2xl mx-auto">
              A complete platform designed for businesses that need reliable, large-scale grocery supplies.
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {features.map((f, i) => (
              <div key={i} className="card group hover:scale-[1.02] transition-all duration-300 hover:border-primary/20">
                <div className="w-12 h-12 rounded-xl bg-primary-light flex items-center justify-center text-primary mb-4 group-hover:bg-primary group-hover:text-white transition-colors duration-300">
                  {f.icon}
                </div>
                <h3 className="text-lg font-semibold text-text-main">{f.title}</h3>
                <p className="mt-2 text-sm text-text-muted leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="how-it-works" className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <h2 className="text-3xl sm:text-4xl font-bold text-text-main">How It Works</h2>
            <p className="mt-4 text-text-muted text-lg max-w-2xl mx-auto">
              Four simple steps to get your bulk groceries delivered to your venue.
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {steps.map((s, i) => (
              <div key={i} className="relative">
                <div className="card text-center py-10 px-6 hover:shadow-lg transition-all duration-300 hover:border-primary/20">
                  <div className="text-5xl font-bold bg-gradient-to-br from-primary/20 to-primary/5 bg-clip-text text-transparent mb-4">
                    {s.step}
                  </div>
                  <h3 className="text-lg font-semibold text-text-main mb-2">{s.title}</h3>
                  <p className="text-sm text-text-muted leading-relaxed">{s.desc}</p>
                </div>
                {i < steps.length - 1 && (
                  <div className="hidden lg:block absolute top-1/2 -right-3 -translate-y-1/2 z-10 text-border">
                    <ArrowRight size={20} />
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-br from-secondary via-secondary to-primary relative overflow-hidden">
        <div className="absolute inset-0 pointer-events-none">
          <div className="absolute top-10 left-10 w-72 h-72 bg-white/5 rounded-full blur-3xl"></div>
          <div className="absolute bottom-10 right-10 w-96 h-96 bg-white/5 rounded-full blur-3xl"></div>
        </div>
        <div className="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl sm:text-4xl font-bold text-white">Ready to Simplify Your Bulk Grocery Procurement?</h2>
          <p className="mt-4 text-lg text-white/70 max-w-2xl mx-auto">
            Join thousands of businesses, event planners, and caterers who trust BulkBasket for their grocery needs.
          </p>
          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link to="/login" className="btn bg-white text-secondary font-semibold text-base px-8 py-3.5 hover:bg-gray-100 shadow-lg hover:-translate-y-[1px] transition-all">
              Get Started Free <ArrowRight size={18} />
            </Link>
            <Link to="/login" className="btn border border-white/30 text-white text-base px-8 py-3.5 hover:bg-white/10 transition-all">
              I'm a Shop Owner
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 bg-white border-t border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            <div className="col-span-2 md:col-span-1">
              <div className="flex items-center gap-2 mb-4">
                <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-primary to-emerald-600 flex items-center justify-center text-white font-bold text-sm">
                  B
                </div>
                <span className="font-bold text-lg text-text-main">BulkBasket</span>
              </div>
              <p className="text-sm text-text-muted leading-relaxed">
                India's leading bulk grocery ordering platform for weddings, events, and businesses.
              </p>
            </div>
            <div>
              <h4 className="font-semibold text-sm text-text-main mb-4">Platform</h4>
              <ul className="space-y-2">
                <li><a href="#features" className="text-sm text-text-muted hover:text-primary transition-colors">Features</a></li>
                <li><a href="#how-it-works" className="text-sm text-text-muted hover:text-primary transition-colors">How It Works</a></li>
                <li><a href="#occasions" className="text-sm text-text-muted hover:text-primary transition-colors">Occasions</a></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold text-sm text-text-main mb-4">Company</h4>
              <ul className="space-y-2">
                <li><a href="#" className="text-sm text-text-muted hover:text-primary transition-colors">About Us</a></li>
                <li><a href="#" className="text-sm text-text-muted hover:text-primary transition-colors">Careers</a></li>
                <li><a href="#" className="text-sm text-text-muted hover:text-primary transition-colors">Contact</a></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold text-sm text-text-main mb-4">Legal</h4>
              <ul className="space-y-2">
                <li><a href="#" className="text-sm text-text-muted hover:text-primary transition-colors">Privacy Policy</a></li>
                <li><a href="#" className="text-sm text-text-muted hover:text-primary transition-colors">Terms of Service</a></li>
                <li><a href="#" className="text-sm text-text-muted hover:text-primary transition-colors">Refund Policy</a></li>
              </ul>
            </div>
          </div>
          <div className="mt-10 pt-6 border-t border-border flex flex-col sm:flex-row items-center justify-between gap-4">
            <p className="text-sm text-text-muted">© 2026 BulkBasket. All rights reserved.</p>
            <div className="flex items-center gap-1 text-sm text-text-muted">
              Made with <span className="text-error mx-1">♥</span> in India
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
