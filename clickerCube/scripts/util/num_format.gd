class_name NumFormat

const SUFFIXES: Array[String] = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]

static func short(value: float) -> String:
	var size := absf(value)
	if size < 1000.0:
		if is_equal_approx(value, roundf(value)):
			return str(int(roundf(value)))
		return String.num(value, 1)
	
	var tier := int(floorf(log(size) / log(1000.0)))
	var scaled := value / pow(1000.0, tier)
	if absf(scaled) >= 999.5:
		tier += 1
		scaled /= 1000.0
	
	if tier >= SUFFIXES.size():
		var exponent := int(floorf(log(size) / log(10.0)))
		return "%se%d" % [String.num(value / pow(10.0, exponent), 2), exponent]
	
	var decimals := 2 if absf(scaled) < 10.0 else (1 if absf(scaled) < 100.0 else 0)
	return String.num(scaled, decimals) + SUFFIXES[tier]
