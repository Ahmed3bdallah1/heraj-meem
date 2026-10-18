class Message {
  final int? id;
  final String? terms;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Message({
    required this.id,
    required this.terms,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["id"],
      terms: json["message"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "terms": terms,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

final dummyMessage = Message(
  id: 1,
  terms: '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Privacy Policy - Heraj</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; padding: 20px; color: #333; }
    h1, h2 { color: #2c3e50; }
    h1 { font-size: 22px; }
    h2 { font-size: 18px; margin-top: 20px; }
    p { margin: 10px 0; }
    ul { margin: 10px 0 20px 20px; }
    strong { color: #2c3e50; }
  </style>
</head>
<body>

  <h1>Privacy Policy – Heraj</h1>
  <p><strong>Effective Date:</strong> January 2025</p>

  <p>Heraj ("we," "our," or "us") values your privacy and is committed to protecting your personal data. 
  This Privacy Policy explains how we collect, use, and safeguard information when you use our mobile application ("App") 
  and related services for our e-commerce marketplace platform.</p>

  <h2>1. Information We Collect</h2>
  <ul>
    <li><strong>Personal Information:</strong> Name, phone number, email address, profile picture, and account details when you register or interact with the App.</li>
    <li><strong>Device Information:</strong> IP address, device model, operating system, app version, and usage statistics.</li>
    <li><strong>Location Data:</strong> With your permission, we may collect location data to show nearby stores, products, and delivery options.</li>
    <li><strong>Transaction Information:</strong> Purchase history, payment methods, shipping addresses, and order details.</li>
    <li><strong>Communication Data:</strong> Messages sent through our in-app chat system with sellers and customer support.</li>
    <li><strong>Content Data:</strong> Product listings, reviews, ratings, and other content you create on the platform.</li>
  </ul>

  <h2>2. How We Use Your Information</h2>
  <ul>
    <li>Facilitate buying and selling transactions on our marketplace.</li>
    <li>Process payments and manage orders.</li>
    <li>Enable communication between buyers and sellers.</li>
    <li>Send order updates, promotional offers, and important notifications.</li>
    <li>Improve our services, analyze usage patterns, and personalize your experience.</li>
    <li>Ensure a safe and trustworthy marketplace environment.</li>
    <li>Comply with legal and regulatory requirements.</li>
    <li>Prevent fraud and abuse.</li>
  </ul>

  <h2>3. Sharing of Information</h2>
  <p>We may share your information with:</p>
  <ul>
    <li><strong>Service Providers:</strong> Payment processors, shipping companies, cloud hosting services, analytics providers, and customer support tools.</li>
    <li><strong>Sellers and Buyers:</strong> When you make a purchase or sell a product, we share necessary information (name, contact details, shipping address) to complete the transaction.</li>
    <li><strong>Business Partners:</strong> Trusted partners who help us operate our platform, only when necessary for service delivery.</li>
    <li><strong>Legal Authorities:</strong> If required by law, regulation, court order, or legal process.</li>
    <li><strong>Business Transfers:</strong> In case of merger, acquisition, or sale of assets, your information may be transferred to the new entity.</li>
  </ul>
  <p>We <strong>do not sell</strong> your personal information to third parties for marketing purposes.</p>

  <h2>4. Data Security</h2>
  <p>We implement industry-standard technical and organizational measures to protect your data against unauthorized access, 
  disclosure, alteration, or destruction. This includes encryption, secure servers, access controls, and regular security audits. 
  However, no system is 100% secure, and we cannot guarantee absolute security.</p>

  <h2>5. Data Retention</h2>
  <p>We retain personal data only as long as necessary for:</p>
  <ul>
    <li>Providing our services and fulfilling transactions</li>
    <li>Complying with legal obligations and tax requirements</li>
    <li>Resolving disputes and enforcing agreements</li>
    <li>Protecting our legitimate business interests</li>
  </ul>
  <p>When data is no longer needed, we securely delete or anonymize it.</p>

  <h2>6. Your Rights</h2>
  <p>Depending on your location, you may have the following rights:</p>
  <ul>
    <li><strong>Access:</strong> Request a copy of your personal data we hold.</li>
    <li><strong>Correction:</strong> Update or correct inaccurate information.</li>
    <li><strong>Deletion:</strong> Request deletion of your personal data (subject to legal requirements).</li>
    <li><strong>Portability:</strong> Receive your data in a structured, machine-readable format.</li>
    <li><strong>Objection:</strong> Object to processing of your data for certain purposes.</li>
    <li><strong>Restriction:</strong> Request restriction of processing in certain circumstances.</li>
    <li><strong>Withdrawal:</strong> Withdraw consent for data processing activities where consent is the legal basis.</li>
  </ul>
  <p>To exercise these rights, please contact us through the App settings or via email.</p>

  <h2>7. Cookies and Tracking Technologies</h2>
  <p>We use cookies, web beacons, and similar technologies to enhance your experience, analyze usage, and deliver personalized content. 
  You can manage cookie preferences through your device settings.</p>

  <h2>8. Third-Party Services</h2>
  <p>Our App may contain links to third-party websites or services. We are not responsible for their privacy practices. 
  We encourage you to read their privacy policies before providing any information.</p>

  <h2>9. Children's Privacy</h2>
  <p>Our services are not directed to children under 18 years of age. We do not knowingly collect personal information from children. 
  If you believe we have collected information from a child, please contact us immediately.</p>

  <h2>10. International Data Transfers</h2>
  <p>Your information may be transferred to and processed in countries other than your country of residence. 
  We ensure appropriate safeguards are in place to protect your data in accordance with this Privacy Policy.</p>

  <h2>11. Updates to This Policy</h2>
  <p>We may update this Privacy Policy from time to time to reflect changes in our practices or legal requirements. 
  Any material changes will be notified through the App or via email. The updated policy will be effective immediately upon posting. 
  We encourage you to review this policy periodically.</p>

  <h2>12. Contact Us</h2>
  <p>If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us:</p>
  <p>
    📧 <a href="mailto:support@esyasatgo.com">support@esyasatgo.com</a><br>
    🌐 <a href="https://esyasatgo.com" target="_blank">www.esyasatgo.com</a><br>
    📱 Through the App: Settings → Help & Support
  </p>
  <p><strong>Last Updated:</strong> January 2025</p>

</body>
</html>
''',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final dummyWhoAreWeMessage = Message(
  id: 2,
  terms: '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Who Are We - Heraj</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; padding: 20px; color: #333; }
    h1, h2 { color: #2c3e50; }
    h1 { font-size: 24px; margin-bottom: 10px; }
    h2 { font-size: 18px; margin-top: 20px; margin-bottom: 10px; }
    p { margin: 10px 0; text-align: justify; }
    ul { margin: 10px 0 20px 20px; }
    .highlight { background-color: #f0f4f8; padding: 15px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #2c3e50; }
    strong { color: #2c3e50; }
  </style>
</head>
<body>

  <h1>Welcome to Heraj</h1>
  
  <div class="highlight">
    <p><strong>Heraj</strong> is your trusted e-commerce marketplace platform, connecting buyers and sellers across Turkey. 
    We provide a comprehensive platform where you can discover thousands of products, from electronics to real estate, 
    and shop with confidence from verified sellers. Whether you're looking to buy or sell, Heraj makes it easy, 
    secure, and convenient.</p>
  </div>

  <h2>Our Mission</h2>
  <p>At Heraj, our mission is to create a vibrant, secure, and user-friendly marketplace that empowers both buyers and sellers. 
  We strive to make online shopping and selling accessible to everyone, providing tools and features that simplify transactions, 
  build trust, and foster a thriving community of users. We believe in making commerce simple, transparent, and rewarding for all.</p>

  <h2>What We Offer</h2>
  <ul>
    <li><strong>Diverse Product Categories:</strong> Browse through a wide variety of products including electronics, fashion, 
    home goods, real estate, and much more. Find exactly what you're looking for with our intuitive search and category filters.</li>
    
    <li><strong>Buy and Sell Platform:</strong> Shop safely from trusted sellers or become a vendor yourself. 
    Create your store, list your products, and start selling today with our easy-to-use vendor tools.</li>
    
    <li><strong>Secure Transactions:</strong> Safe and secure payment processing with multiple payment options to protect 
    your financial information and ensure smooth transactions.</li>
    
    <li><strong>Free Shipping:</strong> Enjoy free shipping on orders 500₺ and above, making shopping more affordable and convenient.</li>
    
    <li><strong>Direct Communication:</strong> Chat directly with sellers through our in-app messaging system to ask questions, 
    negotiate prices, and get instant support.</li>
    
    <li><strong>Order Tracking:</strong> Track your orders in real-time from purchase to delivery, staying informed every step of the way.</li>
    
    <li><strong>Favorites & Wishlist:</strong> Save your favorite products for later and never miss a great deal.</li>
    
    <li><strong>Reviews & Ratings:</strong> Read authentic reviews from other buyers and share your own experiences to help the community.</li>
  </ul>

  <h2>Our Values</h2>
  <ul>
    <li><strong>Customer First:</strong> Your satisfaction is our top priority. We listen to your feedback and continuously 
    improve our platform to serve you better.</li>
    
    <li><strong>Trust & Safety:</strong> We maintain a safe marketplace environment by verifying sellers, monitoring transactions, 
    and providing secure payment options.</li>
    
    <li><strong>Transparency:</strong> Clear pricing, honest product descriptions, transparent policies, and open communication 
    with our community.</li>
    
    <li><strong>Innovation:</strong> We leverage cutting-edge technology to enhance your shopping and selling experience, 
    making our platform faster, smarter, and more user-friendly.</li>
    
    <li><strong>Community:</strong> Building a strong community of buyers and sellers who support each other and grow together.</li>
    
    <li><strong>Accessibility:</strong> Making e-commerce accessible to everyone, regardless of technical expertise or business size.</li>
  </ul>

  <h2>Why Choose Heraj?</h2>
  <p>Heraj stands out in the e-commerce marketplace by offering:</p>
  <ul>
    <li><strong>Wide Product Selection:</strong> Thousands of products across multiple categories, from everyday items to real estate</li>
    <li><strong>Verified Sellers:</strong> Shop with confidence from trusted and verified vendors</li>
    <li><strong>Competitive Prices:</strong> Find the best deals and compare prices from multiple sellers</li>
    <li><strong>Fast Delivery:</strong> Quick and reliable shipping options to get your orders delivered on time</li>
    <li><strong>Excellent Support:</strong> Responsive customer service team ready to help you with any questions or issues</li>
    <li><strong>Mobile-First Design:</strong> Optimized mobile app for shopping and selling on the go</li>
    <li><strong>Easy Vendor Setup:</strong> Simple process to become a seller and start your online store</li>
    <li><strong>Secure Payments:</strong> Multiple secure payment methods with buyer protection</li>
    <li><strong>Free Shipping:</strong> Free delivery on orders 500₺ and above</li>
    <li><strong>Real-Time Chat:</strong> Direct communication with sellers for instant support</li>
  </ul>

  <h2>For Buyers</h2>
  <p>As a buyer on Heraj, you can:</p>
  <ul>
    <li>Browse and discover products from various categories</li>
    <li>Search for specific items using our advanced search features</li>
    <li>Compare prices and read reviews before making a purchase</li>
    <li>Save favorite products to your wishlist</li>
    <li>Track your orders from purchase to delivery</li>
    <li>Chat with sellers for product inquiries</li>
    <li>Leave reviews and ratings to help other buyers</li>
    <li>Enjoy secure payments and buyer protection</li>
  </ul>

  <h2>For Sellers</h2>
  <p>As a seller on Heraj, you can:</p>
  <ul>
    <li>Create your online store easily</li>
    <li>List unlimited products with detailed descriptions and images</li>
    <li>Manage your inventory and track sales</li>
    <li>Communicate directly with buyers through our chat system</li>
    <li>Access analytics and insights about your store performance</li>
    <li>Reach a wide audience of potential customers</li>
    <li>Benefit from our secure payment processing</li>
    <li>Build your brand and grow your business</li>
  </ul>

  <h2>Our Commitment</h2>
  <p>We are committed to providing exceptional service and building long-lasting relationships with our users. 
  Whether you're a buyer looking for great deals, a seller wanting to grow your business, or someone exploring 
  real estate options, Heraj is here to serve you. We continuously work to improve our platform, add new features, 
  and enhance your experience based on your feedback.</p>

  <h2>Join the Heraj Community</h2>
  <p>Become part of our growing community of satisfied buyers and successful sellers. Download the Heraj app, 
  create your account, and start discovering amazing products or open your store today! Experience the convenience 
  of modern e-commerce with the trust and security you deserve.</p>

  <div class="highlight">
    <p><strong>Thank you for choosing Heraj!</strong> We appreciate your trust and look forward to being your 
    preferred marketplace for all your shopping and selling needs.</p>
  </div>

  <h2>Contact Us</h2>
  <p>Have questions or need support? We're here to help!</p>
  <p>
    📧 Email: <a href="mailto:support@esyasatgo.com">support@esyasatgo.com</a><br>
    🌐 Website: <a href="https://esyasatgo.com" target="_blank">www.esyasatgo.com</a><br>
    📱 App Support: Settings → Help & Support
  </p>

  <p style="margin-top: 30px; text-align: center; color: #2c3e50;">
    <strong>Welcome to Heraj – Your Trusted Marketplace!</strong>
  </p>

</body>
</html>
''',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
