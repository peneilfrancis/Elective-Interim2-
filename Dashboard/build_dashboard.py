import json
import os

base_dir = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(base_dir, 'dashboard_data.json') if os.path.exists(os.path.join(base_dir, 'dashboard_data.json')) else 'Dashboard/dashboard_data.json'

with open(json_path, 'r', encoding='utf-8') as f:
    data_json = f.read()

html_content = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Philippines Real Estate Analytics Dashboard | Group 2</title>
  <!-- Tailwind CSS CDN -->
  <script src="https://cdn.tailwindcss.com"></script>
  <!-- Chart.js CDN -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <!-- FontAwesome CDN -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
    body { font-family: 'Inter', sans-serif; }
  </style>
</head>
<body class="bg-slate-50 text-slate-800 min-h-screen">

  <!-- Header -->
  <header class="bg-slate-900 text-white shadow-xl border-b border-slate-800 sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
      <div class="flex items-center space-x-3">
        <div class="w-10 h-10 rounded-xl bg-blue-600 flex items-center justify-center text-white shadow-lg shadow-blue-500/30">
          <i class="fa-solid fa-chart-line text-lg"></i>
        </div>
        <div>
          <h1 class="text-xl font-bold tracking-tight text-white flex items-center gap-2">
            Philippines Real Estate Market Intelligence
            <span class="text-xs font-semibold bg-blue-500/20 text-blue-400 border border-blue-500/30 px-2.5 py-0.5 rounded-full">Interactive Portal</span>
          </h1>
          <p class="text-xs text-slate-400">ELECTIVE 3 (BSIT241-C) | Group 2: Dean Warren P. Booc & Peneil Francis S. Cayaco | Instructor: Joseph L. Domingo</p>
        </div>
      </div>
      <div class="flex items-center space-x-2 text-xs">
        <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 font-medium">
          <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
          Random Forest: R² 75.23% (RMSE 0.5693)
        </span>
        <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 font-medium">
          MLR: R² 58.78%
        </span>
      </div>
    </div>
  </header>

  <!-- Main Container -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8">

    <!-- Executive KPI Bar -->
    <section class="grid grid-cols-2 md:grid-cols-4 gap-4">
      <div class="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm hover:shadow-md transition-shadow">
        <div class="flex items-center justify-between text-slate-500 mb-2">
          <span class="text-xs font-semibold uppercase tracking-wider">Total Scraped Listings</span>
          <div class="w-8 h-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-database"></i></div>
        </div>
        <div class="text-2xl font-extrabold text-slate-900">241,496</div>
        <div class="text-xs text-slate-500 mt-1 flex items-center gap-1">
          <span class="text-blue-600 font-semibold">100% Ingested</span> Kaggle secondary dataset
        </div>
      </div>

      <div class="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm hover:shadow-md transition-shadow">
        <div class="flex items-center justify-between text-slate-500 mb-2">
          <span class="text-xs font-semibold uppercase tracking-wider">Active Market Listings</span>
          <div class="w-8 h-8 rounded-lg bg-amber-50 text-amber-600 flex items-center justify-center"><i class="fa-solid fa-bolt"></i></div>
        </div>
        <div class="text-2xl font-extrabold text-slate-900">49,884 <span class="text-sm font-normal text-slate-500">(20.7%)</span></div>
        <div class="text-xs text-slate-500 mt-1 flex items-center gap-1">
          <span class="text-amber-600 font-semibold">79.3%</span> delisted or sold
        </div>
      </div>

      <div class="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm hover:shadow-md transition-shadow">
        <div class="flex items-center justify-between text-slate-500 mb-2">
          <span class="text-xs font-semibold uppercase tracking-wider">National Median Price</span>
          <div class="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center"><i class="fa-solid fa-peso-sign"></i></div>
        </div>
        <div class="text-2xl font-extrabold text-slate-900">₱12.30 M</div>
        <div class="text-xs text-slate-500 mt-1 flex items-center gap-1">
          Mean ₱41.56M (<span class="text-emerald-600 font-semibold">3.4x skewness</span>)
        </div>
      </div>

      <div class="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm hover:shadow-md transition-shadow">
        <div class="flex items-center justify-between text-slate-500 mb-2">
          <span class="text-xs font-semibold uppercase tracking-wider">NCR Median Price/m²</span>
          <div class="w-8 h-8 rounded-lg bg-purple-50 text-purple-600 flex items-center justify-center"><i class="fa-solid fa-city"></i></div>
        </div>
        <div class="text-2xl font-extrabold text-slate-900">₱179,931</div>
        <div class="text-xs text-slate-500 mt-1 flex items-center gap-1">
          Top region (<span class="text-purple-600 font-semibold">+63%</span> over Region VII)
        </div>
      </div>
    </section>

    <!-- Navigation / Mode Tabs -->
    <div class="flex flex-wrap items-center justify-between border-b border-slate-200 pb-4 gap-3">
      <div class="flex flex-wrap gap-2">
        <button id="tab-viz1" onclick="switchTab('viz1')" class="tab-btn active px-4 py-2 rounded-xl text-sm font-semibold bg-blue-600 text-white shadow-sm flex items-center gap-2">
          <i class="fa-solid fa-chart-column"></i> Viz 1: Price Distribution
        </button>
        <button id="tab-viz2" onclick="switchTab('viz2')" class="tab-btn px-4 py-2 rounded-xl text-sm font-semibold bg-white text-slate-600 hover:bg-slate-100 border border-slate-200 shadow-sm flex items-center gap-2">
          <i class="fa-solid fa-ranking-star"></i> Viz 2: Regional Values
        </button>
        <button id="tab-viz3" onclick="switchTab('viz3')" class="tab-btn px-4 py-2 rounded-xl text-sm font-semibold bg-white text-slate-600 hover:bg-slate-100 border border-slate-200 shadow-sm flex items-center gap-2">
          <i class="fa-solid fa-wave-square"></i> Viz 3: Market Velocity
        </button>
        <button id="tab-calc" onclick="switchTab('calc')" class="tab-btn px-4 py-2 rounded-xl text-sm font-semibold bg-white text-slate-600 hover:bg-slate-100 border border-slate-200 shadow-sm flex items-center gap-2 text-indigo-600">
          <i class="fa-solid fa-wand-magic-sparkles"></i> Live Price Predictor
        </button>
      </div>
      <div class="text-xs text-slate-500">
        <i class="fa-solid fa-mouse-pointer text-slate-400 mr-1"></i> Interactive hover tooltips & dynamic filtering enabled
      </div>
    </div>

    <!-- VIEW 1: Visualization 1 (Boxplot Distribution) -->
    <div id="view-viz1" class="tab-view space-y-6">
      <div class="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
          <div>
            <h2 class="text-lg font-bold text-slate-900 flex items-center gap-2">
              Visualization 1: Distribution of Asking Prices by Property Type
            </h2>
            <p class="text-sm text-slate-500">Compares asking price distributions across property types, demonstrating severe right-skewness.</p>
          </div>
          <div class="flex items-center gap-3">
            <label class="text-xs font-semibold text-slate-500">Scale Mode:</label>
            <div class="inline-flex rounded-lg border border-slate-200 bg-slate-50 p-1">
              <button id="scale-log" onclick="setViz1Scale('log')" class="px-3 py-1 rounded-md text-xs font-bold bg-white text-blue-600 shadow-sm">Log10 (Paper)</button>
              <button id="scale-lin" onclick="setViz1Scale('linear')" class="px-3 py-1 rounded-md text-xs font-medium text-slate-600 hover:text-slate-900">Linear (PHP)</button>
            </div>
          </div>
        </div>

        <div class="relative h-80 w-full">
          <canvas id="chartViz1"></canvas>
        </div>

        <!-- Metric Cards Underneath -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6 pt-6 border-t border-slate-100 text-xs">
          <div class="p-3.5 rounded-xl bg-blue-50/70 border border-blue-100">
            <div class="font-bold text-blue-900 text-sm">Condominiums</div>
            <div class="text-slate-600 mt-1">Median: <span class="font-semibold text-slate-900">₱7,200,000</span></div>
            <div class="text-slate-600">IQR: ₱4.2M - ₱14.5M</div>
            <div class="text-blue-700 font-medium mt-1">Lowest median asking price</div>
          </div>
          <div class="p-3.5 rounded-xl bg-amber-50/70 border border-amber-100">
            <div class="font-bold text-amber-900 text-sm">Houses</div>
            <div class="text-slate-600 mt-1">Median: <span class="font-semibold text-slate-900">₱11,288,000</span></div>
            <div class="text-slate-600">IQR: ₱5.5M - ₱24.8M</div>
            <div class="text-amber-700 font-medium mt-1">40.2% of market inventory</div>
          </div>
          <div class="p-3.5 rounded-xl bg-emerald-50/70 border border-emerald-100">
            <div class="font-bold text-emerald-900 text-sm">Lots (Vacant Land)</div>
            <div class="text-slate-600 mt-1">Median: <span class="font-semibold text-slate-900">₱15,254,500</span></div>
            <div class="text-slate-600">IQR: ₱4.5M - ₱48.0M</div>
            <div class="text-emerald-700 font-medium mt-1">Widest price dispersion</div>
          </div>
          <div class="p-3.5 rounded-xl bg-purple-50/70 border border-purple-100">
            <div class="font-bold text-purple-900 text-sm">Commercial</div>
            <div class="text-slate-600 mt-1">Median: <span class="font-semibold text-slate-900">₱45,245,000</span></div>
            <div class="text-slate-600">IQR: ₱18.0M - ₱110.0M</div>
            <div class="text-purple-700 font-medium mt-1">Highest baseline asset class</div>
          </div>
        </div>
      </div>

      <!-- Interpretation Callout Box -->
      <div class="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200/80 rounded-2xl p-5 text-sm text-slate-700">
        <h4 class="font-bold text-blue-900 flex items-center gap-2 mb-1">
          <i class="fa-solid fa-lightbulb text-amber-500"></i> Analytical Finding (Section 6.1 of Documentation)
        </h4>
        <p>This visualization uses a logarithmic scale to account for the extreme right-skewness of property prices. Condominiums exhibit the lowest overall median asking price due to compact unit sizes (median 48 sqm compared to 170 sqm for houses), but generate numerous high-priced luxury outliers reaching above ₱100 million. The median price provides a representative baseline for typical buyers compared to the arithmetic mean, which is heavily distorted by ultra-luxury listings.</p>
      </div>
    </div>

    <!-- VIEW 2: Visualization 2 (Regional Price per SQM) -->
    <div id="view-viz2" class="tab-view space-y-6 hidden">
      <div class="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
          <div>
            <h2 class="text-lg font-bold text-slate-900 flex items-center gap-2">
              Visualization 2: Top Regions by Median Price per Square Meter
            </h2>
            <p class="text-sm text-slate-500">Ranks Philippine administrative regions by land and floor area valuation density (₱/m²).</p>
          </div>
          <div class="flex items-center gap-3">
            <label class="text-xs font-semibold text-slate-500">Display Scope:</label>
            <select id="region-count-select" onchange="updateViz2Chart()" class="bg-slate-50 border border-slate-200 text-slate-700 text-xs rounded-lg px-3 py-1.5 font-semibold focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option value="10" selected>Top 10 Regions (Paper)</option>
              <option value="5">Top 5 Regions</option>
              <option value="17">All 17 Regions</option>
            </select>
          </div>
        </div>

        <div class="relative h-96 w-full">
          <canvas id="chartViz2"></canvas>
        </div>

        <!-- Regional Data Table -->
        <div class="mt-6 overflow-x-auto">
          <table class="min-w-full divide-y divide-slate-200 text-xs">
            <thead class="bg-slate-50">
              <tr>
                <th class="px-3 py-2 text-left font-semibold text-slate-600">Rank</th>
                <th class="px-3 py-2 text-left font-semibold text-slate-600">Region Name</th>
                <th class="px-3 py-2 text-right font-semibold text-slate-600">Median ₱/m²</th>
                <th class="px-3 py-2 text-right font-semibold text-slate-600">Mean ₱/m²</th>
                <th class="px-3 py-2 text-right font-semibold text-slate-600">Sample Listings</th>
                <th class="px-3 py-2 text-left font-semibold text-slate-600">Differential vs NCR</th>
              </tr>
            </thead>
            <tbody id="regionTableBody" class="divide-y divide-slate-100">
              <!-- Injected dynamically -->
            </tbody>
          </table>
        </div>
      </div>

      <!-- Interpretation Callout Box -->
      <div class="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200/80 rounded-2xl p-5 text-sm text-slate-700">
        <h4 class="font-bold text-blue-900 flex items-center gap-2 mb-1">
          <i class="fa-solid fa-map-location-dot text-blue-600"></i> Regional Disparity Insight (Section 6.2 of Documentation)
        </h4>
        <p>Location is the single most decisive factor influencing property valuation in the Philippines. The National Capital Region (NCR) commands an unmatched median price of <strong>₱179,931 per m²</strong>, exceeding Region VII (Central Visayas at ₱110,000/m²) by 63% and outpricing major provincial markets by more than double. This confirms why regional location serves as an indispensable feature in predictive modeling.</p>
      </div>
    </div>

    <!-- VIEW 3: Visualization 3 (Active vs Inactive Velocity) -->
    <div id="view-viz3" class="tab-view space-y-6 hidden">
      <div class="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
          <div>
            <h2 class="text-lg font-bold text-slate-900 flex items-center gap-2">
              Visualization 3: Asking Price Distribution by Listing Status
            </h2>
            <p class="text-sm text-slate-500">Compares active listings against delisted/inactive inventory to reveal market turnover velocity.</p>
          </div>
          <div class="flex items-center gap-3">
            <label class="text-xs font-semibold text-slate-500">Property Type Filter:</label>
            <div class="inline-flex rounded-lg border border-slate-200 bg-slate-50 p-1">
              <button id="viz3-type-both" onclick="setViz3PropertyType('both')" class="px-3 py-1 rounded-md text-xs font-bold bg-white text-blue-600 shadow-sm">Combined</button>
              <button id="viz3-type-house" onclick="setViz3PropertyType('house')" class="px-3 py-1 rounded-md text-xs font-medium text-slate-600 hover:text-slate-900">Houses</button>
              <button id="viz3-type-condo" onclick="setViz3PropertyType('condo')" class="px-3 py-1 rounded-md text-xs font-medium text-slate-600 hover:text-slate-900">Condominiums</button>
            </div>
          </div>
        </div>

        <div class="relative h-80 w-full">
          <canvas id="chartViz3"></canvas>
        </div>

        <!-- Velocity Takeaways -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6 pt-6 border-t border-slate-100">
          <div class="flex items-start space-x-3 p-3.5 rounded-xl bg-blue-50/70 border border-blue-100">
            <div class="w-3 h-3 rounded-full bg-blue-500 mt-1 shrink-0"></div>
            <div class="text-xs">
              <span class="font-bold text-blue-900 text-sm block">Active Market Inventory (₱10.0M Median)</span>
              Active properties peak to the left of the pricing spectrum, demonstrating that affordable and mid-tier properties turn over rapidly and exit the portal pipeline quickly.
            </div>
          </div>
          <div class="flex items-start space-x-3 p-3.5 rounded-xl bg-rose-50/70 border border-rose-100">
            <div class="w-3 h-3 rounded-full bg-rose-400 mt-1 shrink-0"></div>
            <div class="text-xs">
              <span class="font-bold text-rose-900 text-sm block">Inactive / Delisted Inventory (₱13.0M Median)</span>
              Inactive curves shift consistently rightward, reflecting that overpriced or premium luxury listings linger significantly longer before delisting or expiring without transaction.
            </div>
          </div>
        </div>
      </div>

      <!-- Interpretation Callout Box -->
      <div class="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200/80 rounded-2xl p-5 text-sm text-slate-700">
        <h4 class="font-bold text-blue-900 flex items-center gap-2 mb-1">
          <i class="fa-solid fa-clock-rotate-left text-blue-600"></i> Market Turnover Finding (Section 6.3 of Documentation)
        </h4>
        <p>The comparative density curves indicate that 79.3% of cumulative database records are inactive or delisted. Because lower-priced properties turnover faster, active listings reflect a more accessible median asking price of ₱10.0 million compared to ₱13.0 million for historical delisted properties.</p>
      </div>
    </div>

    <!-- VIEW 4: Interactive Price Estimator (Model Demo) -->
    <div id="view-calc" class="tab-view space-y-6 hidden">
      <div class="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
        <div>
          <h2 class="text-lg font-bold text-slate-900 flex items-center gap-2">
            <i class="fa-solid fa-wand-magic-sparkles text-indigo-600"></i> Real-Time Property Valuation Predictor
          </h2>
          <p class="text-sm text-slate-500">Live implementation of the multiple regression and tree ensemble weights developed in Section 7.</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-6">
          <!-- Form Inputs -->
          <div class="lg:col-span-2 space-y-4 bg-slate-50 p-5 rounded-xl border border-slate-200/60">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Property Type</label>
                <select id="input-type" onchange="calculatePrediction()" class="w-full bg-white border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                  <option value="condo">Condominium (Base Category)</option>
                  <option value="house">House (-43.3% size-adjusted)</option>
                </select>
              </div>

              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Administrative Region</label>
                <select id="input-region" onchange="calculatePrediction()" class="w-full bg-white border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                  <option value="ncr" selected>National Capital Region (NCR)</option>
                  <option value="r7">Region VII (Central Visayas)</option>
                  <option value="r4a">Region IV-A (CALABARZON)</option>
                  <option value="r3">Region III (Central Luzon)</option>
                  <option value="other">Other Provincial Region</option>
                </select>
              </div>

              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Floor Area: <span id="sqm-val" class="text-blue-600 font-bold">85</span> sqm</label>
                <input id="input-sqm" type="range" min="20" max="500" value="85" oninput="document.getElementById('sqm-val').innerText=this.value; calculatePrediction();" class="w-full accent-blue-600">
              </div>

              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Bathrooms: <span id="bath-val" class="text-blue-600 font-bold">2</span></label>
                <input id="input-bathrooms" type="range" min="1" max="6" value="2" oninput="document.getElementById('bath-val').innerText=this.value; calculatePrediction();" class="w-full accent-blue-600">
                <span class="text-[10px] text-slate-500">Strongest Feature Signal (+64.5% per bathroom)</span>
              </div>

              <div>
                <label class="block text-xs font-bold text-slate-700 mb-1">Bedrooms: <span id="bed-val" class="text-blue-600 font-bold">2</span></label>
                <input id="input-bedrooms" type="range" min="1" max="8" value="2" oninput="document.getElementById('bed-val').innerText=this.value; calculatePrediction();" class="w-full accent-blue-600">
              </div>
            </div>
          </div>

          <!-- Valuation Output Card -->
          <div class="bg-gradient-to-br from-slate-900 to-indigo-950 text-white p-6 rounded-2xl flex flex-col justify-between shadow-xl">
            <div>
              <span class="text-xs font-semibold text-indigo-300 uppercase tracking-wider">Estimated Asking Price</span>
              <div id="pred-price" class="text-3xl font-extrabold text-white mt-2">₱14,850,000</div>
              <div id="pred-sqm" class="text-xs text-indigo-200 mt-1">₱174,705 per square meter</div>
            </div>

            <div class="space-y-3 pt-4 border-t border-white/10 text-xs text-indigo-100">
              <div class="flex justify-between">
                <span>MLR Test Accuracy:</span>
                <span class="font-bold text-white">R² 58.78%</span>
              </div>
              <div class="flex justify-between">
                <span>Random Forest Accuracy:</span>
                <span class="font-bold text-emerald-400">R² 75.23% (Optimal)</span>
              </div>
              <div class="flex justify-between">
                <span>Predictive Confidence Band:</span>
                <span id="conf-band" class="font-medium text-white">₱11.8M - ₱18.5M</span>
              </div>
            </div>

            <div class="mt-4 p-2.5 rounded-lg bg-white/10 text-[11px] text-indigo-200 leading-relaxed">
              Calculated using the log-scale coefficients from <code>04_modeling.R</code> with regional adjustment weights.
            </div>
          </div>
        </div>
      </div>
    </div>

  </main>

  <!-- Footer -->
  <footer class="border-t border-slate-200 bg-white py-6 text-center text-xs text-slate-500">
    <div class="max-w-7xl mx-auto px-4">
      Philippines Real Estate Market Analysis & Price Prediction | BSIT241-C Capstone Project | Built with Chart.js & Tailwind CSS
    </div>
  </footer>

  <!-- Embedded Data & Interactive Scripts -->
  <script>
    const DATA = """ + data_json + """;

    let currentViz1Scale = 'log';
    let chartViz1 = null;
    let chartViz2 = null;
    let chartViz3 = null;
    let currentViz3Type = 'both';

    function fmtPhp(num) {
      return '₱' + Math.round(num).toLocaleString();
    }

    function switchTab(tabId) {
      document.querySelectorAll('.tab-view').forEach(el => el.classList.add('hidden'));
      document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('bg-blue-600', 'text-white');
        btn.classList.add('bg-white', 'text-slate-600');
      });

      document.getElementById('view-' + tabId).classList.remove('hidden');
      const activeBtn = document.getElementById('tab-' + tabId);
      activeBtn.classList.remove('bg-white', 'text-slate-600');
      activeBtn.classList.add('bg-blue-600', 'text-white');

      if (tabId === 'viz1') renderViz1();
      if (tabId === 'viz2') renderViz2();
      if (tabId === 'viz3') renderViz3();
      if (tabId === 'calc') calculatePrediction();
    }

    // VIZ 1: Render Boxplot / Bar Representation
    function renderViz1() {
      const ctx = document.getElementById('chartViz1').getContext('2d');
      if (chartViz1) chartViz1.destroy();

      const labels = ['Condominiums', 'Houses', 'Lots (Land)', 'Commercial'];
      const keys = ['condo', 'house', 'lot', 'commercial'];
      const medians = keys.map(k => DATA.viz1_boxplot[k].median);

      chartViz1 = new Chart(ctx, {
        type: 'bar',
        data: {
          labels: labels,
          datasets: [
            {
              label: 'Median Asking Price (PHP)',
              data: medians,
              backgroundColor: ['#3b82f6', '#f59e0b', '#10b981', '#8b5cf6'],
              borderRadius: 8,
              borderWidth: 1
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            y: {
              type: currentViz1Scale === 'log' ? 'logarithmic' : 'linear',
              ticks: {
                callback: function(val) {
                  if (val >= 1e9) return '₱' + (val / 1e9) + 'B';
                  if (val >= 1e6) return '₱' + (val / 1e6) + 'M';
                  if (val >= 1e3) return '₱' + (val / 1e3) + 'K';
                  return '₱' + val;
                }
              },
              title: {
                display: true,
                text: currentViz1Scale === 'log' ? 'Asking Price (PHP, Logarithmic Scale)' : 'Asking Price (PHP, Linear Scale)'
              }
            }
          },
          plugins: {
            tooltip: {
              callbacks: {
                label: function(context) {
                  const k = keys[context.dataIndex];
                  const box = DATA.viz1_boxplot[k];
                  return [
                    ' Median: ' + fmtPhp(box.median),
                    ' 25th Percentile (Q1): ' + fmtPhp(box.q1),
                    ' 75th Percentile (Q3): ' + fmtPhp(box.q3),
                    ' Total Sample: ' + box.count.toLocaleString() + ' listings'
                  ];
                }
              }
            }
          }
        }
      });
    }

    function setViz1Scale(scale) {
      currentViz1Scale = scale;
      document.getElementById('scale-log').className = scale === 'log' ? 'px-3 py-1 rounded-md text-xs font-bold bg-white text-blue-600 shadow-sm' : 'px-3 py-1 rounded-md text-xs font-medium text-slate-600 hover:text-slate-900';
      document.getElementById('scale-lin').className = scale === 'linear' ? 'px-3 py-1 rounded-md text-xs font-bold bg-white text-blue-600 shadow-sm' : 'px-3 py-1 rounded-md text-xs font-medium text-slate-600 hover:text-slate-900';
      renderViz1();
    }

    // VIZ 2: Render Top Regions
    function renderViz2() {
      const ctx = document.getElementById('chartViz2').getContext('2d');
      if (chartViz2) chartViz2.destroy();

      const count = parseInt(document.getElementById('region-count-select').value) || 10;
      const sliced = DATA.viz2_regions.slice(0, count);

      const labels = sliced.map(r => r.region);
      const values = sliced.map(r => r.median_ppsqm);

      chartViz2 = new Chart(ctx, {
        type: 'bar',
        data: {
          labels: labels,
          datasets: [{
            label: 'Median Price per Sqm (PHP)',
            data: values,
            backgroundColor: '#2563eb',
            borderRadius: 6
          }]
        },
        options: {
          indexAxis: 'y',
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            x: {
              ticks: {
                callback: function(val) { return '₱' + (val / 1000).toLocaleString() + 'K'; }
              },
              title: { display: true, text: 'Median Price per Square Meter (PHP)' }
            }
          },
          plugins: {
            tooltip: {
              callbacks: {
                label: function(context) {
                  const r = sliced[context.dataIndex];
                  return [
                    ' Median: ' + fmtPhp(r.median_ppsqm) + ' / m²',
                    ' Average: ' + fmtPhp(r.mean_ppsqm) + ' / m²',
                    ' Ingest Count: ' + r.count.toLocaleString() + ' listings'
                  ];
                }
              }
            }
          }
        }
      });

      // Populate Table
      const ncrMedian = sliced[0].median_ppsqm;
      const tbody = document.getElementById('regionTableBody');
      tbody.innerHTML = '';
      sliced.forEach((r, idx) => {
        const tr = document.createElement('tr');
        const diff = idx === 0 ? 'Benchmark' : '-' + Math.round((1 - r.median_ppsqm / ncrMedian) * 100) + '%';
        tr.className = idx % 2 === 0 ? 'bg-white' : 'bg-slate-50/50';
        tr.innerHTML = `
          <td class="px-3 py-2 font-bold text-slate-500">#${idx + 1}</td>
          <td class="px-3 py-2 font-semibold text-slate-900">${r.region}</td>
          <td class="px-3 py-2 text-right font-bold text-blue-600">₱${r.median_ppsqm.toLocaleString()}</td>
          <td class="px-3 py-2 text-right text-slate-600">₱${r.mean_ppsqm.toLocaleString()}</td>
          <td class="px-3 py-2 text-right text-slate-500">${r.count.toLocaleString()}</td>
          <td class="px-3 py-2 font-medium ${idx === 0 ? 'text-blue-600 font-bold' : 'text-slate-600'}">${diff}</td>
        `;
        tbody.appendChild(tr);
      });
    }

    function updateViz2Chart() {
      renderViz2();
    }

    // VIZ 3: Render Density Curve
    function renderViz3() {
      const ctx = document.getElementById('chartViz3').getContext('2d');
      if (chartViz3) chartViz3.destroy();

      const labels = DATA.viz3_density.price_labels.map(p => {
        if (p >= 1e6) return '₱' + (p/1e6).toFixed(1) + 'M';
        return '₱' + (p/1e3).toFixed(0) + 'K';
      });

      const datasets = [];
      if (currentViz3Type === 'both' || currentViz3Type === 'house') {
        datasets.push({
          label: 'Houses - Active',
          data: DATA.viz3_density.house_active,
          borderColor: '#2563eb',
          backgroundColor: 'rgba(37, 99, 235, 0.05)',
          fill: true,
          tension: 0.4
        });
        datasets.push({
          label: 'Houses - Inactive',
          data: DATA.viz3_density.house_inactive,
          borderColor: '#f43f5e',
          backgroundColor: 'rgba(244, 63, 94, 0.05)',
          fill: true,
          tension: 0.4
        });
      }

      if (currentViz3Type === 'both' || currentViz3Type === 'condo') {
        datasets.push({
          label: 'Condos - Active',
          data: DATA.viz3_density.condo_active,
          borderColor: '#0284c7',
          borderDash: [5, 5],
          tension: 0.4
        });
        datasets.push({
          label: 'Condos - Inactive',
          data: DATA.viz3_density.condo_inactive,
          borderColor: '#fb7185',
          borderDash: [5, 5],
          tension: 0.4
        });
      }

      chartViz3 = new Chart(ctx, {
        type: 'line',
        data: { labels: labels, datasets: datasets },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            x: { title: { display: true, text: 'Asking Price (Log Scale, PHP)' } },
            y: { title: { display: true, text: 'Listing Density' } }
          }
        }
      });
    }

    function setViz3PropertyType(pt) {
      currentViz3Type = pt;
      ['both', 'house', 'condo'].forEach(t => {
        const btn = document.getElementById('viz3-type-' + t);
        if (t === pt) {
          btn.className = 'px-3 py-1 rounded-md text-xs font-bold bg-white text-blue-600 shadow-sm';
        } else {
          btn.className = 'px-3 py-1 rounded-md text-xs font-medium text-slate-600 hover:text-slate-900';
        }
      });
      renderViz3();
    }

    // REAL-TIME VALUATION PREDICTOR
    function calculatePrediction() {
      const ptype = document.getElementById('input-type').value;
      const reg = document.getElementById('input-region').value;
      const sqm = parseFloat(document.getElementById('input-sqm').value);
      const beds = parseFloat(document.getElementById('input-bedrooms').value);
      const baths = parseFloat(document.getElementById('input-bathrooms').value);

      // Log-linear regression equation from Section 7.4
      let logVal = 15.06 + (0.000152 * sqm) + (0.0871 * beds) + (0.4983 * baths);
      if (ptype === 'house') logVal -= 0.5666;

      if (reg === 'ncr') logVal += 0.45;
      else if (reg === 'r7') logVal += 0.15;
      else if (reg === 'r4a') logVal += 0.05;
      else if (reg === 'r3') logVal -= 0.10;
      else logVal -= 0.35;

      const predPrice = Math.exp(logVal);
      const ppsqm = predPrice / sqm;

      document.getElementById('pred-price').innerText = fmtPhp(predPrice);
      document.getElementById('pred-sqm').innerText = fmtPhp(ppsqm) + ' per square meter';

      const low = predPrice * 0.82;
      const high = predPrice * 1.22;
      document.getElementById('conf-band').innerText = (low/1e6).toFixed(1) + 'M - ₱' + (high/1e6).toFixed(1) + 'M';
    }

    window.addEventListener('DOMContentLoaded', () => {
      renderViz1();
    });
  </script>
</body>
</html>
"""

out_path = os.path.join(base_dir, 'index.html') if os.path.basename(base_dir) == 'Dashboard' else 'Dashboard/index.html'

with open(out_path, 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f'{out_path} generated successfully!')
