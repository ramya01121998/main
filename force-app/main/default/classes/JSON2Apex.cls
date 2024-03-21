public class JSON2Apex {

	public String x_id {get;set;}
	public String PartName {get;set;} 
	public Integer TotalQuantityShipped {get;set;} 
	public String PartNumber {get;set;} 
	public Integer PartRiskLevel {get;set;} 
	public String PartDescription {get;set;} 
	public String SKU {get;set;} 
	public String RelatedParts {get;set;} 

	public JSON2Apex(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == '_id') {
						x_id = parser.getText();
					} else if (text == 'Part Name') {
						PartName = parser.getText();
					} else if (text == 'Total Quantity Shipped') {
						TotalQuantityShipped = parser.getIntegerValue();
					} else if (text == 'Part Number') {
						PartNumber = parser.getText();
					} else if (text == 'Part Risk Level') {
						PartRiskLevel = parser.getIntegerValue();
					} else if (text == 'Part Description') {
						PartDescription = parser.getText();
					} else if (text == 'SKU') {
						SKU = parser.getText();
					} else if (text == 'Related Parts') {
						RelatedParts = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static List<JSON2Apex> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfJSON2Apex(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	



    private static List<JSON2Apex> arrayOfJSON2Apex(System.JSONParser p) {
        List<JSON2Apex> res = new List<JSON2Apex>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new JSON2Apex(p));
        }
        return res;
    }


}