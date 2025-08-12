package com.example.common.cache.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.cache.CacheManager;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Set;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
@ConditionalOnProperty(name = "spring.cache.type", havingValue = "redis")
public class CacheService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final CacheManager cacheManager;

    public void put(String cacheName, String key, Object value) {
        try {
            var cache = cacheManager.getCache(cacheName);
            if (cache != null) {
                cache.put(key, value);
                log.debug("Cached item - Cache: {}, Key: {}", cacheName, key);
            }
        } catch (Exception e) {
            log.warn("Failed to cache item - Cache: {}, Key: {}", cacheName, key, e);
        }
    }

    public void put(String cacheName, String key, Object value, Duration ttl) {
        try {
            String redisKey = buildRedisKey(cacheName, key);
            redisTemplate.opsForValue().set(redisKey, value, ttl);
            log.debug("Cached item with TTL - Cache: {}, Key: {}, TTL: {}", cacheName, key, ttl);
        } catch (Exception e) {
            log.warn("Failed to cache item with TTL - Cache: {}, Key: {}", cacheName, key, e);
        }
    }

    @SuppressWarnings("unchecked")
    public <T> T get(String cacheName, String key, Class<T> type) {
        try {
            var cache = cacheManager.getCache(cacheName);
            if (cache != null) {
                var wrapper = cache.get(key, type);
                if (wrapper != null) {
                    log.debug("Cache hit - Cache: {}, Key: {}", cacheName, key);
                    return wrapper;
                }
            }
            log.debug("Cache miss - Cache: {}, Key: {}", cacheName, key);
            return null;
        } catch (Exception e) {
            log.warn("Failed to get cached item - Cache: {}, Key: {}", cacheName, key, e);
            return null;
        }
    }

    public void evict(String cacheName, String key) {
        try {
            var cache = cacheManager.getCache(cacheName);
            if (cache != null) {
                cache.evict(key);
                log.debug("Evicted cache item - Cache: {}, Key: {}", cacheName, key);
            }
        } catch (Exception e) {
            log.warn("Failed to evict cache item - Cache: {}, Key: {}", cacheName, key, e);
        }
    }

    public void evictAll(String cacheName) {
        try {
            var cache = cacheManager.getCache(cacheName);
            if (cache != null) {
                cache.clear();
                log.debug("Evicted all cache items - Cache: {}", cacheName);
            }
        } catch (Exception e) {
            log.warn("Failed to evict all cache items - Cache: {}", cacheName, e);
        }
    }

    public Set<String> getKeys(String pattern) {
        try {
            return redisTemplate.keys(pattern);
        } catch (Exception e) {
            log.warn("Failed to get keys with pattern: {}", pattern, e);
            return Set.of();
        }
    }

    public Boolean hasKey(String cacheName, String key) {
        try {
            String redisKey = buildRedisKey(cacheName, key);
            return redisTemplate.hasKey(redisKey);
        } catch (Exception e) {
            log.warn("Failed to check key existence - Cache: {}, Key: {}", cacheName, key, e);
            return false;
        }
    }

    public Long getExpire(String cacheName, String key) {
        try {
            String redisKey = buildRedisKey(cacheName, key);
            return redisTemplate.getExpire(redisKey, TimeUnit.SECONDS);
        } catch (Exception e) {
            log.warn("Failed to get expiration time - Cache: {}, Key: {}", cacheName, key, e);
            return -1L;
        }
    }

    private String buildRedisKey(String cacheName, String key) {
        return cacheName + "::" + key;
    }
}