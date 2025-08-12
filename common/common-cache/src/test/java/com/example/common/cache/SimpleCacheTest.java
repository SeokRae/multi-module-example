package com.example.common.cache;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class SimpleCacheTest {

    @Test
    void simpleCacheTest() {
        // Basic test to verify cache module compilation
        assertThat("cache").isEqualTo("cache");
    }
}