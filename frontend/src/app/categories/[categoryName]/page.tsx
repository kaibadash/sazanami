'use client';

import { use, useEffect, useState, useRef } from 'react';
import Link from 'next/link';
import { getCategoryMetrics, Metric } from '@/lib/api';
import * as d3 from 'd3';

export default function CategoryMetricsPage({ 
  params 
}: { 
  params: Promise<{ categoryName: string }>
}) {
  const { categoryName } = use(params);
  const [metrics, setMetrics] = useState<Metric[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchMetrics() {
      try {
        const data = await getCategoryMetrics(categoryName);
        setMetrics(data.metrics);
      } catch (err) {
        setError('Failed to fetch metrics');
        console.error(err);
      } finally {
        setLoading(false);
      }
    }

    fetchMetrics();
  }, [categoryName]);

  if (loading) {
    return <div className="p-8 text-center">Loading...</div>;
  }

  if (error) {
    return <div className="p-8 text-center text-red-500">{error}</div>;
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-2">{categoryName}</h1>
      
      {metrics.length === 0 ? (
        <p>No metrics available</p>
      ) : (
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <MultiLineChart metrics={metrics} />
        </div>
      )}
      
      <div className="mt-6">
        <Link 
          href="/categories" 
          className="text-blue-500 hover:underline"
        >
          Back to Categories
        </Link>
      </div>
    </div>
  );
} 

interface MultiLineChartProps {
  metrics: Metric[];
}

function MultiLineChart({ metrics }: MultiLineChartProps) {
  const svgRef = useRef<SVGSVGElement>(null);
  
  useEffect(() => {
    if (!svgRef.current || metrics.length === 0) return;
    
    const margin = { top: 30, right: 140, bottom: 50, left: 60 };
    const width = 800 - margin.left - margin.right;
    const height = 400 - margin.top - margin.bottom;
    
    // SVGをクリア
    d3.select(svgRef.current).selectAll("*").remove();
    
    // 全メトリックのデータを準備
    const allData: {
      metric: Metric;
      data: { date: Date; value: number; valueWithUnit: string }[];
    }[] = [];
    
    metrics.forEach(metric => {
      if (metric.values.length === 0) return;
      
      const metricData = metric.values.map(v => ({
        date: new Date(v.recorded_at),
        value: parseFloat(v.value.replace(/,/g, '')),
        valueWithUnit: v.value_with_unit
      })).sort((a, b) => a.date.getTime() - b.date.getTime());
      
      allData.push({
        metric,
        data: metricData
      });
    });
    
    if (allData.length === 0) {
      return;
    }
    
    // SVG要素の作成
    const svg = d3.select(svgRef.current)
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", `translate(${margin.left},${margin.top})`);
    
    // グリッド線の追加
    const gridColor = "#2a2f3a";
    
    // 背景を追加
    svg.append("rect")
      .attr("width", width)
      .attr("height", height)
      .attr("fill", "#1a1e27");
    
    // 全てのデータポイントを結合して日付の範囲を取得
    const allDates = allData.flatMap(d => d.data.map(point => point.date));
    const xDomain = d3.extent(allDates) as [Date, Date];
    
    // 全てのデータポイントから最大値を取得
    const allValues = allData.flatMap(d => d.data.map(point => point.value));
    const maxValue = d3.max(allValues) as number;
    
    // X軸のスケール
    const x = d3.scaleTime()
      .domain(xDomain)
      .range([0, width]);
    
    // Y軸のスケール
    const y = d3.scaleLinear()
      .domain([0, maxValue * 1.1])
      .range([height, 0]);
    
    // カラースケール - カスタムカラーパレット
    const colorPalette = [
      "#ff7e5f", "#feb47b", "#7dd3fc", "#60a5fa", "#818cf8", 
      "#a78bfa", "#c084fc", "#e879f9", "#f472b6", "#fb7185"
    ];
    const color = d3.scaleOrdinal(colorPalette);
    
    // グリッドラインを追加
    svg.append("g")
      .attr("class", "grid")
      .selectAll("line")
      .data(y.ticks(5))
      .enter()
      .append("line")
      .attr("x1", 0)
      .attr("x2", width)
      .attr("y1", d => y(d))
      .attr("y2", d => y(d))
      .attr("stroke", gridColor)
      .attr("stroke-dasharray", "3,3");
    
    // X軸の追加
    svg.append("g")
      .attr("transform", `translate(0,${height})`)
      .call(
        d3.axisBottom(x)
          .ticks(6)
          .tickSize(0)
      )
      .call(g => g.select(".domain").remove())
      .selectAll("text")
      .style("font-size", "12px")
      .style("fill", "#94a3b8");
    
    // Y軸の追加
    svg.append("g")
      .call(
        d3.axisLeft(y)
          .ticks(5)
          .tickSize(0)
      )
      .call(g => g.select(".domain").remove())
      .selectAll("text")
      .style("font-size", "12px")
      .style("fill", "#94a3b8");
    
    // ツールチップの作成
    const tooltip = d3.select("body").append("div")
      .attr("class", "tooltip")
      .style("position", "absolute")
      .style("visibility", "hidden")
      .style("background", "rgba(15, 23, 42, 0.95)")
      .style("color", "white")
      .style("border", "none")
      .style("border-radius", "6px")
      .style("padding", "12px")
      .style("box-shadow", "0 4px 12px rgba(0,0,0,0.2)")
      .style("pointer-events", "none")
      .style("z-index", "10")
      .style("font-size", "14px")
      .style("min-width", "150px");
    
    // 各メトリックの折れ線とポイントを追加
    allData.forEach((metricData, i) => {
      const metricColor = color(i.toString());
      
      // 折れ線の追加
      svg.append("path")
        .datum(metricData.data)
        .attr("fill", "none")
        .attr("stroke", metricColor)
        .attr("stroke-width", 3)
        .attr("stroke-linecap", "round")
        .attr("stroke-linejoin", "round")
        .attr("d", d3.line<{date: Date, value: number}>()
          .curve(d3.curveMonotoneX)
          .x(d => x(d.date))
          .y(d => y(d.value))
        );
      
      // データポイントの追加
      const dots = svg.selectAll(`dot-${i}`)
        .data(metricData.data)
        .enter().append("circle")
        .attr("r", 6)
        .attr("cx", d => x(d.date))
        .attr("cy", d => y(d.value))
        .attr("fill", metricColor)
        .attr("stroke", "#1a1e27")
        .attr("stroke-width", 2)
        .style("transition", "all 0.2s ease")
        .style("cursor", "pointer");
        
      // ホバー効果とツールチップ
      dots.on("mouseover", function(event, d) {
          d3.select(this)
            .attr("r", 9)
            .attr("stroke-width", 3);
            
          tooltip
            .style("visibility", "visible")
            .html(`
              <div style="border-left: 4px solid ${metricColor}; padding-left: 8px;">
                <div style="font-weight: bold; margin-bottom: 4px;">${metricData.metric.label}</div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 2px;">
                  <span style="color: #94a3b8;">Date:</span>
                  <span>${d.date.toLocaleDateString()}</span>
                </div>
                <div style="display: flex; justify-content: space-between;">
                  <span style="color: #94a3b8;">Value:</span>
                  <span>${d.valueWithUnit}</span>
                </div>
              </div>
            `)
            .style("left", (event.pageX + 15) + "px")
            .style("top", (event.pageY - 20) + "px");
        })
        .on("mouseout", function() {
          d3.select(this)
            .attr("r", 6)
            .attr("stroke-width", 2);
            
          tooltip.style("visibility", "hidden");
        });
      
      // 凡例の追加
      const legendGroup = svg.append("g")
        .attr("transform", `translate(${width + 25}, ${i * 30})`);
        
      legendGroup.append("circle")
        .attr("r", 6)
        .attr("fill", metricColor)
        .attr("stroke", "#1a1e27")
        .attr("stroke-width", 1.5);
        
      legendGroup.append("text")
        .attr("x", 15)
        .attr("y", 0)
        .attr("dy", "0.35em")
        .text(metricData.metric.label)
        .style("font-size", "14px")
        .style("fill", "#e2e8f0");
    });
    
    // X軸ラベル
    svg.append("text")
      .attr("text-anchor", "middle")
      .attr("x", width / 2)
      .attr("y", height + 40)
      .text("Date")
      .style("fill", "#cbd5e1")
      .style("font-size", "14px");
    
    // Y軸ラベル
    svg.append("text")
      .attr("text-anchor", "middle")
      .attr("transform", "rotate(-90)")
      .attr("y", -margin.left + 15)
      .attr("x", -height / 2)
      .text("Value")
      .style("fill", "#cbd5e1")
      .style("font-size", "14px");
    
    return () => {
      tooltip.remove();
    };
  }, [metrics]);
  
  return (
    <div>
      <svg 
        ref={svgRef} 
        className="rounded-lg"
        style={{ width: '100%', height: '450px', maxWidth: '900px', margin: '0 auto' }}
      ></svg>
    </div>
  );
} 