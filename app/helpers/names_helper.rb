require 'net/http'

module NamesHelper
  # == 한글 인코딩의 이해 2편: 유니코드와 Java를 이용한 한글 처리
  #  * http://helloworld.naver.com/helloworld/19187
  #  * http://helloworld.naver.com/helloworld/76650
  # == 유니코드 정규화
  #  * http://ko.wikipedia.org/wiki/%EC%9C%A0%EB%8B%88%EC%BD%94%EB%93%9C_%EC%A0%95%EA%B7%9C%ED%99%94
  # == 한글 자모
  #  * http://m.korean.go.kr/hangeul/principle/001.html

  # 한글자모
  HANGUL_JAMO_RANGE               = (0x1100..0x11FF)
  HANGUL_JA_RANGE                 = (0x1100..0x1112)
  # 한글 소리마디 영역 "가".."힣"
  HANGUL_SYLLABLES_RANGE          = (0xAC00..0xD7AF)
  # 호환용 한글자모
  HANGUL_COMPATIBILITY_JAMO_RANGE = (0x3130..0x318F)
  HANGUL_COMPATIBILITY_JA_RANGE   = (0x3131..0x314e)
  # 한글 자모 확장B
  HANGUL_JAMO_EXTENDED_B_RANGE    = (0xD7B0..0xD7FF)

  TABLE_FOR_CHO = %w(ㄱ ㄲ ㄴ ㄷ ㄸ ㄹ ㅁ ㅂ ㅃ ㅅ ㅆ ㅇ ㅈ ㅉ ㅊ ㅋ ㅌ ㅍ ㅎ)
  TABLE_FOR_JUNG = %w(ㅏ ㅐ ㅑ ㅒ ㅓ ㅔ ㅕ ㅖ ㅗ ㅘ ㅙ ㅚ ㅛ ㅜ ㅝ ㅞ ㅟ ㅠ ㅡ ㅢ ㅣ)
  TABLE_FOR_JONG = [ nil, 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ',
    'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ' ]

  STROKES = {
    'ㄱ' => 2, 'ㄲ' => 4, 'ㄴ' => 2, 'ㄷ' => 3, 'ㄸ' => 6, 'ㄹ' => 5, 'ㅁ' => 4,
    'ㅂ' => 4, 'ㅃ' => 8, 'ㅅ' => 2, 'ㅆ' => 4, 'ㅇ' => 1, 'ㅈ' => 3, 'ㅉ' => 6,
    'ㅊ' => 4, 'ㅋ' => 3, 'ㅌ' => 4, 'ㅍ' => 4, 'ㅎ' => 3,
    'ㅏ' => 2, 'ㅐ' => 3, 'ㅑ' => 3, 'ㅒ' => 4, 'ㅓ' => 2, 'ㅔ' => 3, 'ㅕ' => 3,
    'ㅖ' => 4, 'ㅗ' => 2, 'ㅘ' => 4, 'ㅙ' => 5, 'ㅚ' => 3, 'ㅛ' => 3, 'ㅜ' => 2,
    'ㅝ' => 4, 'ㅞ' => 5, 'ㅟ' => 3, 'ㅠ' => 3, 'ㅡ' => 1, 'ㅢ' => 2, 'ㅣ' => 1,
    'ㄳ' => 4, 'ㄵ' => 5, 'ㄶ' => 5, 'ㄺ' => 7, 'ㄻ' => 9, 'ㄼ' => 9, 'ㄽ' => 7,
    'ㄾ' => 9, 'ㄿ' => 9, 'ㅀ' => 8, 'ㅄ' => 6,
    nil => 0
  }

  def hangul? string
    string.codepoints.each do |i|
      return false unless HANGUL_JAMO_RANGE === i \
        or HANGUL_SYLLABLES_RANGE === i \
        or HANGUL_COMPATIBILITY_JAMO_RANGE === i \
        or HANGUL_JAMO_EXTENDED_B_RANGE === i
    end
    true
  end

  def hangul_ja? char
    HANGUL_COMPATIBILITY_JAMO_RANGE === char.codepoints.first
  end

  def splitable_hangul? char
    HANGUL_SYLLABLES_RANGE === char.codepoints.first
  end

  def split_hangul char
    point = char.codepoints.first
    case point
    when HANGUL_SYLLABLES_RANGE
      uni_value = point - 0xAC00
      jong = uni_value % 28
      cho  = ( ( uni_value - jong ) / 28 ) / 21
      jung = ( ( uni_value - jong ) / 28 ) % 21
      [TABLE_FOR_CHO[cho], TABLE_FOR_JUNG[jung], TABLE_FOR_JONG[jong]]
    else
      char
    end
  end

  def count_strokes string
    string.chars.map{ |char|
      (split_hangul char).map{ |c| STROKES[c] }.inject(:+)
    }
  end

  def to_strokes foo, bar
    f = foo.chars
    b = bar.chars
    baz = Array.new(foo.size){ "#{f.shift}#{b.shift}" }.join ''
    ((count_strokes baz).join '').to_i
    z = count_strokes baz
    loop {
      break if z.size <= 2
      (z.size - 1).times { z << (z.shift + z[0]) % 10 }
      z.shift
    }
    z.join('').to_i
  end

  def to_strokes_from list
    c_list = list.map{ |x| x.chars }
    baz = Array.new(c_list.first.size){ c_list.map{ |x| x.shift }.join '' }.join ''
    ((count_strokes baz).join '').to_i
    z = count_strokes baz
    loop {
      break if z.size <= 2
      (z.size - 1).times { z << (z.shift + z[0]) % 10 }
      z.shift
    }
    z.join('').to_i
  end

  def to_korean word
    a = Net::HTTP.get("translate.naver.com",
      "/koreaPron.dic?query=#{word}&srcLang=en&tarLang=ko")
    a.force_encoding('UTF-8').strip
  end

  def to_strokes_global foo, bar
    foo = foo.split.map{ |x| to_korean x }.join '' unless hangul? foo
    bar = bar.split.map{ |x| to_korean x }.join '' unless hangul? bar
    [foo, bar, to_strokes(foo, bar)]
  end
end
