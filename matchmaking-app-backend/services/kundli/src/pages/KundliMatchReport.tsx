import React, { useEffect, useState } from "react";
import ProfileCard from "@/components/ProfileCard";
import ProgressBar from "@/components/ProgressBar";
type KundliMatchResult = {
  vedic_score: number;
  ai_match_score: number;
  nlp_score: number;
  verdict: string;
  explanation: string[];
  remedies: string[];
  guna_analysis: string[];
  compatibility_score: number;
  name1: string;
  name2: string;
  caste1: string;
  caste2: string;
};
const KundliMatchReport = () => {
  const [result, setResult] = useState<KundliMatchResult | null>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    fetch("http://127.0.0.1:5055/api/kundli/hybrid", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        person1: {
          name: "Amit Sharma",
          birth_date: "1990-01-01",
          birth_time: "12:00:00",
          latitude: 28.6139,
          longitude: 77.2090,
        },
        person2: {
          name: "Anita Patel",
          birth_date: "1992-05-10",
          birth_time: "15:30:00",
          latitude: 19.0760,
          longitude: 72.8777,
        },
      }),
    })
      .then((res) => res.json())
      .then((data) => setResult(data))
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);
  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <p className="text-lg text-gray-500">Loading Kundli Match Report...</p>
      </div>
    );
  }
  if (!result) {
    return (
      <div className="flex items-center justify-center h-screen">
        <p className="text-lg text-red-500">Failed to load report. Please try again.</p>
      </div>
    );
  }
  return (
    <div className="max-w-3xl mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6 text-center">💍 Kundli Match Report</h1>
      <ProfileCard
        name1={result.name1 || "Amit Sharma"}
        name2={result.name2 || "Anita Patel"}
        caste1={result.caste1 || "Brahmin from North India"}
        caste2={result.caste2 || "Patidar from Gujarat"}
      />
      <div className="my-6">
        <h2 className="text-xl font-semibold mb-2">Overall Verdict</h2>
        <p className="p-3 bg-green-100 rounded-lg border">{result.verdict}</p>
      </div>
      <div className="my-6">
        <h2 className="text-xl font-semibold mb-2">Compatibility Score</h2>
        <ProgressBar value={result.compatibility_score} />
        <p className="text-center mt-2">{result.compatibility_score}/100</p>
      </div>
      <div className="my-6">
        <h2 className="text-xl font-semibold mb-2">Guna Matching Analysis</h2>
        <ul className="space-y-2">
          {result.guna_analysis?.map((item, index) => (
            <li
              key={index}
              className="p-3 rounded-lg border"
            >
              {item}
            </li>
          ))}
        </ul>
      </div>
      <div className="my-6">
        <h2 className="text-xl font-semibold mb-2">Detailed Explanations</h2>
        <ul className="space-y-2">
          {result.explanation.map((item, index) => (
            <li
              key={index}
              className="p-3 rounded-lg bg-red-50 border border-red-300"
            >
              {item}
            </li>
          ))}
        </ul>
      </div>
      <div className="my-6">
        <h2 className="text-xl font-semibold mb-2">Recommended Remedies</h2>
        <ul className="space-y-2">
          {result.remedies.map((item, index) => (
            <li
              key={index}
              className="p-3 rounded-lg bg-blue-50 border border-blue-300"
            >
              {item}
            </li>
          ))}
        </ul>
      </div>
      <div className="my-6">
        <h2 className="text-xl font-semibold mb-2">Scores</h2>
        <p className="mb-2">Vedic Guna Score: {result.vedic_score}</p>
        <p className="mb-2">AI Match Score: {result.ai_match_score}</p>
        <p className="mb-2">NLP Sentiment Score: {result.nlp_score}</p>
      </div>
    </div>
  );
};
export default KundliMatchReport;