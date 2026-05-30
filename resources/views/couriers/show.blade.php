@extends('layouts.app')

@section('page-title', 'Detail Courier')

@section('content')
    <div class="container-fluid">

        {{-- Header --}}
        <div class="d-flex justify-content-between align-items-start mb-4">

            <div>
                <h1 class="fw-bold mb-2">
                    Detail Courier
                </h1>

                <p class="text-muted mb-0">
                    Informasi lengkap courier EcoTrash
                </p>
            </div>

            <a href="{{ route('couriers.index') }}" class="btn btn-outline-secondary rounded-pill px-4">

                ← Kembali

            </a>

        </div>

        {{-- Profile --}}
        <div class="card border-0 shadow-sm rounded-4 mb-4">

            <div class="card-body p-4">

                <div class="row align-items-center">

                    <div class="col-md-8">

                        <h2 class="fw-bold mb-2">
                            {{ $courier->name }}
                        </h2>

                        <p class="text-muted mb-2">
                            {{ $courier->email }}
                        </p>

                        <p class="mb-0">
                            {{ $courier->phone ?? '-' }}
                        </p>

                    </div>

                    <div class="col-md-4 text-md-end">

                        {{-- Active Status --}}
                        @if($courier->is_active)
                            <span class="badge bg-success fs-6 px-3 py-2">
                                Aktif
                            </span>
                        @else
                            <span class="badge bg-danger fs-6 px-3 py-2">
                                Nonaktif
                            </span>
                        @endif

                        <br><br>

                        {{-- Action Button --}}
                        <form action="{{ route('couriers.toggle-status', $courier->id) }}" method="POST" class="d-inline">
                            @csrf

                            @if($courier->is_active)
                                <button type="submit" class="btn btn-warning rounded-pill px-4">
                                    Nonaktifkan Courier
                                </button>
                            @else
                                <button type="submit" class="btn btn-success rounded-pill px-4">
                                    Aktifkan Courier
                                </button>
                            @endif
                        </form>

                    </div>

                </div>

            </div>

        </div>

        {{-- Stats --}}
        <div class="row g-4 mb-4">

            {{-- Rating --}}
            <div class="col-md-4">

                <div class="card border-0 shadow-sm rounded-4 h-100">

                    <div class="card-body">

                        <small class="text-muted d-block mb-2">
                            Rating
                        </small>

                        <h2 class="fw-bold text-warning mb-0">
                            ⭐
                            {{ number_format($courier->courierProfile?->rating ?? 0, 1) }}
                        </h2>

                    </div>

                </div>

            </div>

            {{-- Total Waste Collected --}}
            <div class="col-md-4">

                <div class="card border-0 shadow-sm rounded-4 h-100">

                    <div class="card-body">

                        <small class="text-muted d-block mb-2">
                            Total Sampah Diambil
                        </small>

                        <h2 class="fw-bold text-success mb-0">
                            {{ number_format($courier->courierProfile?->totalWasteCollected() ?? 0, 2) }} kg
                        </h2>

                    </div>

                </div>

            </div>

            {{-- Online --}}
            <div class="col-md-4">

                <div class="card border-0 shadow-sm rounded-4 h-100">

                    <div class="card-body">

                        <small class="text-muted d-block mb-2">
                            Status Online
                        </small>

                        @if($courier->is_online)
                            <span class="badge bg-info fs-6 px-3 py-2">
                                Online
                            </span>
                        @else
                            <span class="badge bg-secondary fs-6 px-3 py-2">
                                Offline
                            </span>
                        @endif

                    </div>

                </div>

            </div>

        </div>

        {{-- Vehicle + Location --}}
        <div class="row g-4">

            {{-- Vehicle --}}
            <div class="col-lg-6">

                <div class="card border-0 shadow-sm rounded-4 h-100">

                    <div class="card-body p-4">

                        <h3 class="fw-bold mb-4">
                            Informasi Kendaraan
                        </h3>

                        <div class="mb-4">

                            <small class="text-muted d-block">
                                Vehicle Type
                            </small>

                            <h4 class="fw-semibold mb-0">
                                {{ $courier->courierProfile?->vehicle_type ?? '-' }}
                            </h4>

                        </div>

                        <div>

                            <small class="text-muted d-block">
                                Vehicle Plate
                            </small>

                            <h4 class="fw-semibold mb-0">
                                {{ $courier->courierProfile?->vehicle_plate ?? '-' }}
                            </h4>

                        </div>

                    </div>

                </div>

            </div>

            {{-- Location --}}
            <div class="col-lg-6">

                <div class="card border-0 shadow-sm rounded-4 h-100">

                    <div class="card-body p-4">

                        <h3 class="fw-bold mb-4">
                            Informasi Lokasi Courier
                        </h3>

                        <div class="mb-4">

                            <small class="text-muted d-block">
                                Address
                            </small>

                            <h5 class="fw-semibold mb-0">
                                {{ $courier->courierProfile?->address ?? '-' }}
                            </h5>

                        </div>

                        <div class="row">

                            <div class="col-6">

                                <small class="text-muted d-block">
                                    City
                                </small>

                                <h6 class="fw-semibold">
                                    {{ $courier->courierProfile?->city ?? '-' }}
                                </h6>

                            </div>

                            <div class="col-6">

                                <small class="text-muted d-block">
                                    Province
                                </small>

                                <h6 class="fw-semibold">
                                    {{ $courier->courierProfile?->province ?? '-' }}
                                </h6>

                            </div>

                        </div>

                    </div>

                </div>

            </div>

           <div class="dashboard-card mt-4">

    <h3 class="section-title mb-2">
        Dokumen Verifikasi Courier
    </h3>

    <p class="text-muted mb-4">
        Dokumen identitas courier untuk verifikasi akun
    </p>

    <div class="row g-4">

        {{-- KTP --}}
        <div class="col-lg-4">

            <div class="document-card">

                <h5>KTP</h5>

                @if($courier->courierProfile?->ktp_photo)

                    <img
                        src="{{ asset('storage/' . $courier->courierProfile?->ktp_photo) }}"
                        class="document-image"
                        alt="KTP"
                    >

                @else

                    <div class="document-empty">
                        Belum ada foto KTP
                    </div>

                @endif

            </div>

        </div>

        {{-- SIM --}}
        <div class="col-lg-4">

            <div class="document-card">

                <h5>SIM</h5>

                @if($courier->courierProfile?->sim_photo)

                    <img
                        src="{{ asset('storage/' . $courier->courierProfile?->sim_photo) }}"
                        class="document-image"
                        alt="SIM"
                    >

                @else

                    <div class="document-empty">
                        Belum ada foto SIM
                    </div>

                @endif

            </div>

        </div>

        {{-- Selfie --}}
        <div class="col-lg-4">

            <div class="document-card">

                <h5>Selfie</h5>

                @if($courier->courierProfile?->face_photo)

                    <img
                        src="{{ asset('storage/' . $courier->courierProfile?->face_photo) }}"
                        class="document-image"
                        alt="Selfie"
                    >

                @else

                    <div class="document-empty">
                        Belum ada foto selfie
                    </div>

                @endif

            </div>

        </div>

    </div>

</div> 

        </div>

    </div>
@endsection