const { GoogleGenerativeAI, SchemaType } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const getSystemInstruction = (scanType) => {
  if (scanType === 'food') {
    return `
You are a certified nutritionist and food analysis assistant.
Your task is to analyze an image of a food item or a meal.
Identify the food, its likely ingredients, and its general nutritional profile.
If the image is blurry, unreadable, or does not contain food, set the 'error' field explaining the issue and leave all other fields empty.

Evaluate the overall meal.
Assign an overall healthiness score from 0-100.
Interpretation:
0-29: Poor nutritional quality, Highly processed, or very unhealthy.
30-69: Moderately healthy, Should be consumed in moderation.
70-100: Generally healthy, Suitable for regular consumption for most adults.
Classify the identified core components/ingredients into the predefined categories: Natural Ingredient, Artificial Color, Artificial Sweetener, Preservative, Emulsifier, Stabilizer, Thickener, Flavor Enhancer, Oil/Fat, Sugar, Salt, Vitamin, Mineral, Acidity Regulator, Antioxidant, Unknown.
For every identified key ingredient/component provide:
* healthScore (number 0-100)
* category (string)
* avoid (boolean)
* reason (string)
* details (string)
Explain in plain English. Use evidence-based nutritional guidance. Avoid fear-mongering. If scientific evidence is mixed, clearly state that.
Never invent components if you are completely unsure, but you can make educated estimates based on the visual appearance of the food. explicitly mention uncertainty.
Always return valid JSON matching the exact schema requested.
Never return Markdown. Never return code blocks.
`;
  }

  return `
You are a certified food ingredient analysis assistant.
Your task is to analyze the ingredient list from a food product image.
Extract every ingredient accurately.
If the image is blurry, unreadable, or does not contain an ingredient list, set the 'error' field explaining the issue and leave all other fields empty.

Evaluate the entire product rather than judging ingredients independently.
Assign an overall healthiness score from 0-100.
Interpretation:
0-29: Poor nutritional quality, Highly processed, Contains multiple concerning ingredients.
30-69: Moderately healthy, Some ingredients should be consumed in moderation.
70-100: Generally healthy, Suitable for regular consumption for most adults.
Classify every ingredient into the predefined categories: Natural Ingredient, Artificial Color, Artificial Sweetener, Preservative, Emulsifier, Stabilizer, Thickener, Flavor Enhancer, Oil/Fat, Sugar, Salt, Vitamin, Mineral, Acidity Regulator, Antioxidant, Unknown.
For every ingredient provide:
* healthScore (number 0-100)
* category (string)
* avoid (boolean)
* reason (string)
* details (string)
Explain in plain English. Use evidence-based nutritional guidance. Avoid fear-mongering. If scientific evidence is mixed, clearly state that.
Never invent ingredients. If uncertain, explicitly mention uncertainty.
Always return valid JSON matching the exact schema requested.
Never return Markdown. Never return code blocks.
`;
};

const responseSchema = {
  type: SchemaType.OBJECT,
  properties: {
    error: { type: SchemaType.STRING, description: "Set this if the image is blurry or unreadable" },
    productName: { type: SchemaType.STRING },
    overallHealthScore: { type: SchemaType.INTEGER },
    overallIndicator: { type: SchemaType.STRING, enum: ['GREEN', 'YELLOW', 'RED'] },
    summary: { type: SchemaType.STRING },
    goodIngredients: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
    neutralIngredients: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
    badIngredients: {
      type: SchemaType.ARRAY,
      items: {
        type: SchemaType.OBJECT,
        properties: {
          ingredient: { type: SchemaType.STRING },
          category: { type: SchemaType.STRING },
          healthScore: { type: SchemaType.INTEGER },
          indicator: { type: SchemaType.STRING, enum: ['GREEN', 'YELLOW', 'RED'] },
          avoid: { type: SchemaType.BOOLEAN },
          reason: { type: SchemaType.STRING },
          details: { type: SchemaType.STRING }
        },
        required: ["ingredient", "category", "healthScore", "indicator", "avoid", "reason", "details"]
      }
    },
    warnings: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
    healthBenefits: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
    healthRisks: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
    recommendedFor: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
    notRecommendedFor: { type: SchemaType.ARRAY, items: { type: SchemaType.STRING } },
    disclaimer: { type: SchemaType.STRING }
  }
  // We cannot require all fields if we want to allow an error-only response.
  // Instead, we just require nothing and handle it in the backend logic, or we can make them all optional.
};

const analyzeImage = async (imageBuffer, mimeType, userProfileText = "", scanType = "ingredient") => {
  const promptText = scanType === 'food'
    ? 'Analyze this food image. '
    : 'Analyze this food ingredient list. ';
  const prompt = `${promptText}${userProfileText ? "Take into account the following user profile for personalized recommendations: " + userProfileText : ""}`;

  const imageParts = [
    {
      inlineData: {
        data: imageBuffer.toString("base64"),
        mimeType
      }
    }
  ];

  const attemptModel = async (modelName) => {
    const model = genAI.getGenerativeModel({
      model: modelName,
      systemInstruction: getSystemInstruction(scanType),
      generationConfig: {
        responseMimeType: "application/json",
        responseSchema: responseSchema,
      }
    });

    const result = await model.generateContent([prompt, ...imageParts]);
    const response = await result.response;
    return JSON.parse(response.text());
  };

  try {
    return await attemptModel("gemini-3.5-flash");
  } catch (error) {
    console.warn(`Primary model (gemini-3.5-flash) failed: ${error.message}. Attempting fallback...`);

    try {
      return await attemptModel("gemini-3.5-flash-lite");
    } catch (fallbackError) {
      console.error('Fallback model (gemini-3.5-flash-lite) also failed:', fallbackError);

      let cleanMessage = 'Failed to analyze the image. Please try again later.';
      if (fallbackError.message && fallbackError.message.includes('503')) {
        cleanMessage = 'Our AI servers are currently experiencing high demand. Please try again in a few moments.';
      } else if (fallbackError.message) {
        // Strip out the ugly Google Generative AI prefix
        cleanMessage = fallbackError.message.replace(/\[GoogleGenerativeAI Error\]:\s*/g, '');
      }

      throw new Error(cleanMessage);
    }
  }
};

module.exports = { analyzeImage };
