package com.kc1vmz.osmtilecache.factory;

import io.micronaut.context.annotation.Factory;
import io.micronaut.core.convert.TypeConverter;
import jakarta.inject.Singleton;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Optional;

@Factory
public class ZoneDateTimeConverters {

    @Singleton
    public TypeConverter<ZonedDateTime, String> zonedDateTimeToString() {
        return (source, targetType, context) -> 
            Optional.of(source.format(DateTimeFormatter.ISO_ZONED_DATE_TIME));
    }

    @Singleton
    public TypeConverter<CharSequence, ZonedDateTime> stringToZonedDateTime() {
        return (source, targetType, context) -> {
            try {
                return Optional.of(ZonedDateTime.parse(source.toString(), DateTimeFormatter.ISO_ZONED_DATE_TIME));
            } catch (Exception e) {
                context.reject(source, e);
                return Optional.empty();
            }
        };
    }
}
