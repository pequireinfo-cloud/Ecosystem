// Mock dynamic support content for now, but served from the real backend
exports.getSupportContent = async (req, res) => {
  const type = req.params.type; // 'faq', 'privacy', 'about', 'terms'

  const content = {
    faq: [
      { q: "How to book a service?", a: "Go to the home page, select a category, and click on a professional." },
      { q: "How to pay?", a: "You can pay via the app after the service is completed." }
    ],
    privacy: "Pequire respects your privacy. We collect data only to provide better services...",
    about: "Pequire connects you with top-rated local professionals in minutes.",
    terms: "By using Pequire, you agree to follow our community guidelines..."
  };

  if (content[type]) {
    res.status(200).json({ success: true, data: content[type] });
  } else {
    res.status(404).json({ success: false, message: 'Content type not found' });
  }
};
